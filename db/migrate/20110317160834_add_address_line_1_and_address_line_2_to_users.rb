class AddAddressLine1AndAddressLine2ToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :address_line_1, :string
    add_column :users, :address_line_2, :string
  end

  def self.down
    remove_column :users, :address_line_2
    remove_column :users, :address_line_1
  end
end
