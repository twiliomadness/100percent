class AddRecordingUrlToPhoneCall < ActiveRecord::Migration
  def change
    add_column :phone_calls, :recording_url, :string
  end
end