class RenameVpaPollingPlaceIdInVotersBackToWhatYouWouldNormallyExpect < ActiveRecord::Migration
  def self.up
    rename_column :voters, :vpa_polling_place_id, :polling_place_id
  end

  def self.down
    rename_column :voters, :polling_place_id, :vpa_polling_place_id
  end
end