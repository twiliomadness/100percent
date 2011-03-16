class CreateIncomingMessages < ActiveRecord::Migration
  def self.up
    create_table :incoming_messages do |t|
      t.integer :user_id, :null => false
      t.string :text, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :incoming_messages
  end
end
