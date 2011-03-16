class RemoveIndexFromUsersOnEmail < ActiveRecord::Migration
  def self.up
    remove_index :users, :email
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
