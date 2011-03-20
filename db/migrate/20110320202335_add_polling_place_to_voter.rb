class AddPollingPlaceToVoter < ActiveRecord::Migration
  def self.up
    add_column :voters, :polling_place_id, :string
  end

  def self.down
    remove_column :voters, :polling_place_id
  end
end
