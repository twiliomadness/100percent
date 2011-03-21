class Voter < ActiveRecord::Base
  belongs_to :user
  has_many :incoming_messages, :conditions => {:type => 'IncomingMessage'} 
  has_many :outgoing_messages, :conditions => {:type => 'OutgoingMessage'} 
  belongs_to :polling_place

  # TODO: Add validation of address format here?
  # number and name are required.  Punctuation and apt/suite # s/b removed
  
end
