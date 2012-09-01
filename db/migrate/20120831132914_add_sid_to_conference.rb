class AddSidToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :sid, :string
  end
end