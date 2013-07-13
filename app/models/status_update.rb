class StatusUpdate
  include Mongoid::Document
  
  # Relations
  belongs_to :data_source
end
