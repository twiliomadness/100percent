class RemoveVoterType < ActiveRecord::Migration
  def up
    remove_column :voters, :type
  end

  def down
  end
end