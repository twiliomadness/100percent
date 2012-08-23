class CreateConferences < ActiveRecord::Migration
  def self.up
    create_table :conferences do |t|
      t.integer :user_incoming
      t.integer :user_outgoing
      t.text :transcript
      t.string :audio_link
      t.integer :rating

      t.timestamps
    end
  end

  def self.down
    drop_table :conferences
  end
end
