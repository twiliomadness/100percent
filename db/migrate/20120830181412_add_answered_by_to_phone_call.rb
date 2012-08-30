class AddAnsweredByToPhoneCall < ActiveRecord::Migration
  def change
    add_column :phone_calls, :answered_by, :string
    rename_column :phone_calls, :type, :call_type
  end
end