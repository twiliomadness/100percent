class AddHelpStateToSmsVoter < ActiveRecord::Migration
  def self.up
    add_column :voters, :help_status, :string
    add_column :voters, :conversation_status, :string
  end

  def self.down
    remove_column :voters, :help_status
    remove_column :voters, :conversation_status
  end
end
