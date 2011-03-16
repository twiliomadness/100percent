class AddDateOfBirthToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :date_of_birth, :date
  end

  def self.down
    remove_column :users, :date_of_birth
  end
end
