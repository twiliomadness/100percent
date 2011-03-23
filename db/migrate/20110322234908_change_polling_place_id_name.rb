class ChangePollingPlaceIdName < ActiveRecord::Migration
  def self.up
    rename_column :polling_places, :polling_place_id, :vpa_polling_place_id
  end

  def self.down
    rename_column :polling_places, :vpa_polling_place_id, :polling_place_id
  end
end