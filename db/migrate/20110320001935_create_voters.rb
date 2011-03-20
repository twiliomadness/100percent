class CreateVoters < ActiveRecord::Migration
  def self.up
    create_table :voters do |t|
      t.integer :user_id
      t.string  :type
      t.string   "phone_number"
      t.string   "first_name"
      t.string   "last_name"
      t.string   "city"
      t.string   "status"
      t.string   "zip"
      t.date     "date_of_birth"
      t.string   "address_line_1"
      t.string   "address_line_2"
      t.timestamps
    end

    rename_column :incoming_messages, :user_id, :voter_id
  end

  def self.down
    drop_table :voters
    rename_column :incoming_messages, :voter_id, :user_id
  end
end
