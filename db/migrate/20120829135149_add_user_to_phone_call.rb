class AddUserToPhoneCall < ActiveRecord::Migration
  def change
    add_column :phone_calls, :user_id, :integer
  end
end