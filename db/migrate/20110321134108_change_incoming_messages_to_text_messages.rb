class ChangeIncomingMessagesToTextMessages < ActiveRecord::Migration
  def self.up
      rename_table :incoming_messages, :text_messages
  end 
  def self.down
      rename_table :text_messages, :incoming_messages
  end
end
