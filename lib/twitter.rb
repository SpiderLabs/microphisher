class Twitter
  USER_TIMELINE_SIZE = 200
  USER_TIMELINE_PATH = '/1.1/statuses/user_timeline.json'
  USER_INFORMATION_PATH = '/1.1/users/show.json'
  
  def initialize(access_token)
    @access_token = access_token
  end
  
  # TODO: Proper error handling
  # TODO: Twitter only returns the latest 3,200 tweets for a given
  # user timeline; is there some way to overcome this?
  def tweets(username)
    tweet_request = self._tweets_request(username)
    tweet_list_json = @access_token.get(tweet_request).body
    tweet_list = JSON.parse(tweet_list_json)
    
    # TODO: We should act proactively in order to avoid being
    # rate limited; Twitter explicitly mentions applications which
    # consistently exceed rate limiting will be blacklisted
    while tweet_list.size > 0 && tweet_list.first['errors'].nil?
      tweet_list.each { |tweet| yield tweet }
      max_id = tweet_list.min_by { |tweet| tweet['id'].to_i }['id']
      tweet_request = self._tweets_request(username, max_id)
      tweet_list_json = @access_token.get(tweet_request).body
      tweet_list = JSON.parse(tweet_list_json)
    end
  end
  
  def is_valid_user?(screen_name)
    user_request = self._user_information_request(screen_name)
    user_information_json = @access_token.get(user_request).body
    user_information = JSON.parse(user_information_json)
    user_information['errors'].nil?
  end

  protected
  def _tweets_request(username, max_id = nil)
    get_parameters = { 'screen_name' => username, 'count' => USER_TIMELINE_SIZE }
    get_parameters['max_id'] = max_id unless max_id.nil?
    get_request = Net::HTTP::Get.new(USER_TIMELINE_PATH)
    get_request.set_form_data(get_parameters)
    "#{USER_TIMELINE_PATH}?#{get_request.body}"
  end
  
  def _user_information_request(screen_name)
    get_parameters = { 'screen_name' => screen_name }
    get_request = Net::HTTP::Get.new(USER_INFORMATION_PATH)
    get_request.set_form_data(get_parameters)
    "#{USER_INFORMATION_PATH}?#{get_request.body}"
  end
end