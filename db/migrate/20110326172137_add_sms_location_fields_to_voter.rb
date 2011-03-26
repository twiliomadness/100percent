class AddSmsLocationFieldsToVoter < ActiveRecord::Migration
  def self.up
    add_column :voters, :sms_city, :string
    add_column :voters, :sms_state, :string
    add_column :voters, :sms_zip, :string
  end

  def self.down
    remove_column :voters, :sms_zip
    remove_column :voters, :sms_state
    remove_column :voters, :sms_city
  end
end