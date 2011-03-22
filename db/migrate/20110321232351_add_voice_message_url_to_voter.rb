class AddVoiceMessageUrlToVoter < ActiveRecord::Migration
  def self.up
    add_column :voters, :voice_recording_url, :string
  end

  def self.down
    remove_column :voters, :voice_recording_url
  end
end
