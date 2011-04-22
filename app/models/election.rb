class Election < ActiveRecord::Base
  ELECTION_TYPES = ["Statewide", "Senate", "Assembly"]
  belongs_to :jurisdiction
end
