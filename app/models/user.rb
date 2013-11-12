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

class User
  include Mongoid::Document
  
  # Attribute listing
  field :name, type: String
  field :real_name, type: String
  field :profile_image_url, type: String
  field :oauth_token, type: String
  field :oauth_secret, type: String
  
  # Validations
  validates :name, :real_name, :avatar, :oauth_token, :oauth_secret, presence: true
  validates :name, uniqueness: true
  
  # Relations
  has_many :unknown_subjects
  
  # Return an OAuth::AccessToken for the current user
  def access_token
    oauth_config = YAML.load_file('config/oauth.yml')[Rails.env]
    oauth_consumer = OAuth::Consumer.new oauth_config['consumer_key'],
      oauth_config['consumer_secret'], { :site => oauth_config['site'] }
    OAuth::AccessToken.new(oauth_consumer, oauth_token, oauth_secret)
  end
  
  # Return a user instance based on an OAuth::AccessToken instance
  def self.login(access_token)
    user_identity_json = access_token.get('/1.1/account/verify_credentials.json').body
    user_identity = JSON.parse(user_identity_json)
    
    # First, check if user already exists in database
    user = User.find_by(name: user_identity['screen_name'])
    
    # In case it does not, create the user based on information from
    # OAuth provider (Twitter, in this case)
    if user.nil?
      # Create the User instance
      user = User.create(:id => user_identity['id'],
        :name => user_identity['screen_name'],
        :real_name => user_identity['name'],
        :profile_image_url => user_identity['profile_image_url'],
        :oauth_token => access_token.token,
        :oauth_secret => access_token.secret)
    else
      # If the user unlinks microphisher from this Twitter account
      # and tries to use the app again, a new oauth_token/oauth_secret
      # tuple will be issued, and we need to update the persisted
      # instance accordingly
      if user.oauth_token != access_token.token ||
        user.oauth_secret != access_token.secret
        user.oauth_token = access_token.token
        user.oauth_secret = access_token.secret
        user.save!
      end
    end
    
    user
  end
end

