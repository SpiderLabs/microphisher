class Twitter
  USER_TIMELINE_SIZE = 200
  USER_TIMELINE_PATH = '/1.1/statuses/user_timeline.json'
  
  def initialize(access_token)
    @access_token = access_token
  end
  
  # TODO: Proper error handling
  def tweets(username)
    tweet_request = self._tweets_request(username)
    $stderr.puts("Requesting #{tweet_request}")
    tweet_list_json = @access_token.get(tweet_request).body
    tweet_list = JSON.parse(tweet_list_json)
    
    while tweet_list.size > 0 && tweet_list.first.
      $stderr.puts(tweet_list_json) if tweet_list.size < 5
      $stderr.puts("Tweet count: #{tweet_list.size}")
      tweet_list.each { |tweet| yield tweet }
      max_id = tweet_list.min_by { |tweet| tweet['id'].to_i }['id']
      tweet_request = self._tweets_request(username, max_id)
      tweet_list_json = @access_token.get(tweet_request).body
      tweet_list = JSON.parse(tweet_list_json)
    end
  end
  
  protected
  def _tweets_request(username, max_id = nil)
    get_parameters = { 'screen_name' => username, 'count' => USER_TIMELINE_SIZE }
    get_parameters['max_id'] = max_id unless max_id.nil?
    get_request = Net::HTTP::Get.new(USER_TIMELINE_PATH)
    get_request.set_form_data(get_parameters)
    "#{USER_TIMELINE_PATH}?#{get_request.body}"
  end
end