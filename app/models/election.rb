class Election < ActiveRecord::Base
  ELECTION_TYPES = ["Statewide", "Senate", "Assembly"]
  belongs_to :jurisdiction
  scope :pending, lambda {
    where('date >= ?', Time.now)
  }
  scope :next_election, pending.first
end
