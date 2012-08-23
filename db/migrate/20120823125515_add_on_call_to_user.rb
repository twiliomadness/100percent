class AddOnCallToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :on_call, :boolean
  end

  def self.down
    remove_column :users, :on_call
  end
end