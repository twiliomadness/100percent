class ChangePollingPlaceIdForVoters < ActiveRecord::Migration
  def self.up
    remove_column :voters, :polling_place_id
    add_column :voters, :vpa_polling_place_id, :integer
  end

  def self.down
  end
end