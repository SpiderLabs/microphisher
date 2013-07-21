# Check out https://dev.twitter.com/docs/platform-objects/tweets for the general
# structure of Twitter fields; we just provide field types relevant to the
# filtering/profiling process
class StatusUpdate
  include Mongoid::Document
  
  # Attribute listing
  field :created_at, type: DateTime
  
  # Relations
  belongs_to :data_source
end
