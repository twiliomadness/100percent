class CreateCountyClerks < ActiveRecord::Migration
  def self.up
    create_table :county_clerks do |t|
      t.string :location_name
      t.string :address
      t.string :city
      t.string :zip
      t.string :county
      t.string :phone_number
      t.string :email_address

      t.timestamps
    end
  end

  def self.down
    drop_table :county_clerks
  end
end
