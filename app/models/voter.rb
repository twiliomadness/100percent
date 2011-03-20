class Voter < ActiveRecord::Base
  belongs_to :user
  has_many :incoming_messages

  # TODO: Add validation of address format here?
  # number and name are required.  Punctuation and apt/suite # s/b removed
  
end
