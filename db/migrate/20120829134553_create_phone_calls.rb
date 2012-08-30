class CreatePhoneCalls < ActiveRecord::Migration
  def change
    create_table :phone_calls do |t|
      t.string :callSID
      t.string :type
      t.string :status

      t.timestamps
    end
  end
end
