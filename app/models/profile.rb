class Profile
  include Mongoid::Document

  # Relations
  belongs_to :unknown_subject
end
