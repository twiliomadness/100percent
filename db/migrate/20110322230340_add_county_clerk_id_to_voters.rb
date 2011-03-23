class AddCountyClerkIdToVoters < ActiveRecord::Migration
  def self.up
    add_column :voters, :county_clerk_id, :integer
  end

  def self.down
    remove_column :voters, :county_clerk_id
  end
end
