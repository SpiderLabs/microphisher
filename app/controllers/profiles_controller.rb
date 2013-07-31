class ProfilesController < ApplicationController
  # Word delimiting regexp
  WORD_DELIMITER = /[\.!\?\,:; ]+/
  URL_REGEXP = /\s*http(s)?\S+/
  
  before_filter :load_unknown_subject
  
  def load_unknown_subject
    @unknown_subject = UnknownSubject.find(params[:unknown_subject_id])
  end
  
  def search
    # First build a filter which restricts status updates to data sources
    # associated with the current unknown subject
    data_source_ids = @unknown_subject.data_sources.map { |ds| ds.id }
    source = StatusUpdate.in(data_source_id: data_source_ids)
    
    # Next we filter this list based on the user provided criteria
    criteria_filter = self._build_filter(params)
    criteria_filter.each do |criteria|
      if criteria[:operator] == 'match'
        next_source = source.all(criteria[:field].to_sym => Regexp.new(criteria[:value]))
      elsif criteria[:operator] == 'not_match'
        next_source = source.not.all(criteria[:field].to_sym => Regexp.new(criteria[:value]))
      end
      source = next_source
    end
    session[:criteria_selector] = source
    
    # Finally, provide a view-accessible cursor for all elegible
    # status updates
    @page = params[:page] || 1
    @status_updates = source.desc(:created_at).page(@page)
  end
  
  def create
    @profile = @unknown_subject.profiles.new(params[:profile])
    @profile.selector = session[:criteria_selector].selector
    @profile.save!
    @profile.delay.build_profile!
    redirect_to [ @unknown_subject, @profile ]
  end
  
  def show
    @profile = @unknown_subject.profiles.find(params[:id])
  end
  
  def destroy
    @profile = @unknown_subject.profiles.find(params[:id])
    @profile.destroy
    redirect_to @unknown_subject
  end
  
  def input
    @profile = @unknown_subject.profiles.find(params[:id])
  end
  
  def nlp_tree
    @profile = @unknown_subject.profiles.find(params[:id])
  end

  def validate
    @profile = @unknown_subject.profiles.find(params[:id])
    @text_input = params[:text]
    
    response = [
      { :id => 'word_count', :label => 'Word Count',
        :value => _word_count_ranking(@text_input, @profile) },
      { :id => 'word_usage', :label => 'Word Usage',
        :value => _word_usage_ranking(@text_input, @profile) },
      { :id => 'user_references', :label => 'User References',
        :value => _user_reference_ranking(@text_input, @profile) },
      { :id => 'user_references', :label => 'Hashtag References',
        :value => _hashtag_reference_ranking(@text_input, @profile) }
    ]
    
    respond_to do |format|
      format.json { render :json => response.to_json }
    end
  end
  
  def autocomplete
    @profile = @unknown_subject.profiles.find(params[:id])
    @word = params[:word]
    
    dictionary = nil
    if @word.match(/@/)
      dictionary = @profile.user_mentions
    elsif @word.match(/#/)
      dictionary = @profile.hashtag_mentions
    else
      dictionary = @profile.dictionary
    end
    
    result = dictionary.find_all do |entry|
      entry[0].match(Regexp.new("^#{@word}", Regexp::IGNORECASE))
    end.sort do |a,b|
      b[1] <=> a[1]
    end.map do |entry|
      "#{entry[0]} (#{entry[1]})"
    end
    
    respond_to do |format|
      format.json { render :json => result }
    end
  end

  protected
  def _build_filter(params)
    (0..(params[:profile_criteria_field].size - 1)).map do |index|
      {
        :field    => params[:profile_criteria_field][index],
        :operator => params[:profile_criteria_operator][index],
        :value    => params[:profile_criteria_value][index]
      }
    end
  end
  
  # User reference criteria is defined as the ratio of known user references
  # against unknown references in the input text; a text like
  # 'Some tweet @valid_user_1 @valid_user_2 @invalid_user' would rank
  # 66%, because 1/3 of its referenced users are unknown
  #
  def _user_reference_ranking(text, profile)
    user_references = text.split(WORD_DELIMITER).find_all do |word|
      word.match(/^@/)
    end
    
    return 100 if user_references.size == 0

    user_references.inject(0) do |ranking, user|
      ranking + (profile.user_mentions.has_key?(user) ? (100 / user_references.size) : 0)
    end
  end
  
  # Hashtag reference criteria is defined as the ratio of valid hashtag
  # references against invalid references in the input text; a text like
  # 'Some tweet #known_tag_1 #known_tag_2 #unknown_tag' would rank
  # 66%, because 1/3 of its referenced hashtags are unknown
  #
  def _hashtag_reference_ranking(text, profile)
    hashtag_references = text.split(WORD_DELIMITER).find_all do |word|
      word.match(/^#/)
    end
    
    return 100 if hashtag_references.size == 0

    hashtag_references.inject(0) do |ranking, hashtag|
      ranking + (profile.hashtag_mentions.has_key?(hashtag) ? (100 / hashtag_references.size) : 0)
    end
  end
  
  # Word count ranking is defined as the distance between the number of
  # words in a status update versus the average length for the profile
  # status update collection; anything below 1/3 or above 5/3 of the
  # average value is ranked 0, while other values are proportional to
  # how close they are to the average value
  #
  def _word_count_ranking(text, profile)
    # Count the number of words in current text
    text_word_count = text.split(WORD_DELIMITER).size
    
    return 0 if text_word_count < 1 * profile.average_word_count / 3
    return 0 if text_word_count > 5 * profile.average_word_count / 3
    
    100 - (100 * (text_word_count - profile.average_word_count).abs /
      (2 * profile.average_word_count / 3))
  end
  
  # Word usage is simple -- all words used in a status update must be
  # previously known, being present in a status update present in the
  # profile collection; every time an unknown word is used it decreases
  # the ranking
  #
  def _word_usage_ranking(text, profile)
    # The word list must be filtered of stop words, otherwise that might
    # affect our word usage rank incorrectly
    word_list = text.gsub(URL_REGEXP, '').split(WORD_DELIMITER).reject do |word|
      word.match(/^[@#]/) || profile.stop_words.member?(word.downcase)
    end

    return 100 if word_list.size == 0

    word_list.inject(0) do |ranking, word|
      ranking + (profile.dictionary.has_key?(word.downcase) ? (100 / word_list.size) : 0)
    end
  end
end
