class RemoveVoterFieldsFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :phone_number
    remove_column :users, :zip
    remove_column :users, :date_of_birth
    remove_column :users, :address_line_1
    remove_column :users, :address_line_2
  end

  def self.down
    add_column :users, :phone_number, :string
    add_column :users, :zip, :string
    add_column :users, :date_of_birth, :string
    add_column :users, :address_line_1, :string
    add_column :users, :address_line_2, :string
  end
end
