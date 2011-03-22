# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

  create_table "county_clerks", :force => true do |t|
    t.string   "location_name"
    t.string   "address"
    t.string   "city"
    t.string   "zip"
    t.string   "county"
    t.string   "phone_number"
    t.string   "email_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  
  create_table "polling_places", :force => true do |t|
    t.string   "location_name"
    t.string   "address"
    t.string   "city"
    t.string   "zip"
    t.string   "hours"
    t.integer  "polling_place_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "text_messages", :force => true do |t|
    t.integer  "voter_id",   :null => false
    t.string   "text",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => ""
    t.string   "encrypted_password",   :limit => 128, :default => ""
    t.string   "password_salt",                       :default => ""
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "city"
    t.string   "status"
    t.string   "phone_number"
  end

  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "voters", :force => true do |t|
    t.integer  "user_id"
    t.string   "type"
    t.string   "phone_number"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "city"
    t.string   "status"
    t.string   "zip"
    t.date     "date_of_birth"
    t.string   "address_line_1"
    t.string   "address_line_2"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "polling_place_id"
    t.date     "registration_date"
    t.string   "registration_status"
    t.boolean  "has_voted"
    t.string   "voice_recording_url"
    t.integer  "state_voter_id"
    t.string   "help_status"
    t.string   "conversation_status"
  end

end
