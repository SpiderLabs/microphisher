class Twitter
  USER_TIMELINE_PATH = '/1.1/statuses/user_timeline.json'
  
  def initialize(access_token)
    @access_token = access_token
  end
  
  def tweets(username)
    tweet_list_json = @access_token.get("#{USER_TIMELINE_PATH}?screen_name=#{username}&count=200").body
    tweet_list = JSON.parse(tweet_list_json)
  end
end