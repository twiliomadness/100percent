class ChangeTypeToElectionTypeInElections < ActiveRecord::Migration
  def self.up
    rename_column :elections, :type, :election_type
  end

  def self.down
    rename_column :elections, :election_type, :type
  end
end
