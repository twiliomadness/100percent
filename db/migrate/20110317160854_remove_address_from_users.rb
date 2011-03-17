class RemoveAddressFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :address
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
