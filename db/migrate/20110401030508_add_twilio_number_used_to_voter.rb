class AddTwilioNumberUsedToVoter < ActiveRecord::Migration
  def self.up
    add_column :voters, :twilio_number_used, :string
  end

  def self.down
    remove_column :voters, :twilio_number_used
  end
end