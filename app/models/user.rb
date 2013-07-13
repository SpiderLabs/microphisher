class User
  include Mongoid::Document
  
  # Attribute listing
  field :name, type: String
  field :real_name, type: String
  field :avatar, type: String
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
        :avatar => user_identity['profile_image_url'],
        :oauth_token => access_token.token,
        :oauth_secret => access_token.secret)
    end
    
    user
  end
end
