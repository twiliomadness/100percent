class SetUsersEmailToNull < ActiveRecord::Migration
  def self.up
    change_column :users, :email, :string, :null => true
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
