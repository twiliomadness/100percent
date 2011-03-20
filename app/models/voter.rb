class Voter < ActiveRecord::Base
  belongs_to :user
  has_many :incoming_messages

end
