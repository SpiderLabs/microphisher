#
# microphisher - a spear phishing support tool
#
# Created by Ulisses Albuquerque & Joaquim Espinhara
# Copyright (C) 2013 Trustwave Holdings, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

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
