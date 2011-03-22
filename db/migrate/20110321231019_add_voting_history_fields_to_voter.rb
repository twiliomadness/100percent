class AddVotingHistoryFieldsToVoter < ActiveRecord::Migration
  def self.up
    add_column :voters, :registration_date, :date
    add_column :voters, :registration_status, :string
    add_column :voters, :has_voted, :boolean
  end

  def self.down
    remove_column :voters, :registration_date
    remove_column :voters, :registration_status
    remove_column :voters, :has_voted
  end
end
