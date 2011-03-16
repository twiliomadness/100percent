class SetUsersPasswordToNull < ActiveRecord::Migration
  def self.up
    change_column :users, :encrypted_password, :string, :limit => 128, :null => true
    change_column :users, :password_salt, :string, :null => true
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
