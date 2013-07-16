class OauthController < ApplicationController
  before_filter :setup_oauth
  skip_filter :require_login, :only => [ :login, :authorize ]

  def setup_oauth
    oauth_config = YAML.load_file('config/oauth.yml')[Rails.env]
    @consumer = OAuth::Consumer.new oauth_config['consumer_key'],
      oauth_config['consumer_secret'], {
        :site => oauth_config['site'],
        :request_token_path => oauth_config['request_token_path'],
        :access_token_path  => oauth_config['access_token_path'],
        :authorize_path     => oauth_config['authorize_path'],
       }
  end

  # /oauth/login should be used whenever we want to start an OAuth authorization
  # request using the OAuth::Consumer configured in #setup_oauth
  #
  def login
    oauth_callback = url_for(:action => :authorize)
    request_token = @consumer.get_request_token(:oauth_callback => oauth_callback)
    session[:request_token] = request_token
    redirect_to request_token.authorize_url
  end
  
  # /oauth/logout should be used whenever we want to remove user information
  # from the current session
  #
  def logout
    session[:user] = nil
    redirect_to :controller => :home
  end  

  # /oauth/authorize is the callback URL where we are redirected to after the user
  # grants the application access to his OAuth credentials
  #
  def authorize
    oauth_verifier = params[:oauth_verifier]
    request_token = session[:request_token]
    access_token = request_token.get_access_token(:oauth_verifier => oauth_verifier)
    
    user = User.login(access_token)
    session[:user] = user.id unless user.nil?
    redirect_to :controller => :home
  end
end
