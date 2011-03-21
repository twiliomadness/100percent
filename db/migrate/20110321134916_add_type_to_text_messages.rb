class AddTypeToTextMessages < ActiveRecord::Migration
  def self.up
    add_column :text_messages, :type, :string
  end

  def self.down
    remove_column :text_messages, :type
  end
end
