require 'twitter'

class DataSource
  include Mongoid::Document

  # Attribute listing
  field :user_id, type: String
  field :last_crawl, type: DateTime
  
  # Validations
  validates :user_id, presence: true
  
  # Relations
  belongs_to :unknown_subject
  has_many :status_updates

  def fetch_status_updates
    twitter = Twitter.new(unknown_subject.user.access_token)
    twitter.tweets(self.user_id).each do |tweet|
      next if status_updates.find(tweet['id'])
      status_update = status_updates.new
      tweet.each { |k,v| status_update[k] = v }
      status_update.save
    end
  end
end
