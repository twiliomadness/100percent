class RenameStateToStatus < ActiveRecord::Migration
  def self.up
    rename_column :users, :state, :status
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
