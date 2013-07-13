class UnknownSubject
  include Mongoid::Document
  
  # Attribute listing
  field :name, type: String
  field :aliases, type: Array, default: []
  field :description, type: String
  
  # Validations
  validates :name, presence: true
  
  # Relations
  belongs_to :user
  has_many :data_sources
end
