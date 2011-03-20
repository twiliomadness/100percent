class CreatePollingPlaces < ActiveRecord::Migration
  def self.up
    create_table :polling_places do |t|
      t.string :location_name
      t.string :address
      t.string :city
      t.string :zip
      t.string :hours
      t.integer :polling_place_id

      t.timestamps
    end
  end

  def self.down
    drop_table :polling_places
  end
end
