class CreateJurisdictions < ActiveRecord::Migration
  def self.up
    create_table :jurisdictions do |t|
      t.string :type
      t.integer :district_id

      t.timestamps
    end
    add_index :jurisdictions, [:type, :district_id], :unique => true
  end

  def self.down
    remove_index :jurisdictions, :column => [:type, :district_id]
    drop_table :jurisdictions
  end
end
