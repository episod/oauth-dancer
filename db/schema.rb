# This file is auto-generated from the current state of the database. Instead of editing this file,
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100305213015) do

  create_table "access_tokens", :force => true do |t|
    t.string   "label"
    t.string   "oauth_token"
    t.string   "oauth_token_secret"
    t.integer  "service_provider_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "service_providers", :force => true do |t|
    t.string   "label"
    t.text     "note"
    t.string   "consumer_key"
    t.string   "consumer_secret"
    t.string   "request_token_url"
    t.string   "authorize_url"
    t.string   "access_token_url"
    t.string   "oauth_version",                     :default => "1.0"
    t.string   "default_response_content_type",     :default => "application/x-www-form-urlencoded; charset=utf-8"
    t.string   "default_request_content_type",      :default => "application/x-www-form-urlencoded; charset=utf-8"
    t.string   "oauth_scheme",                      :default => "header"
    t.boolean  "use_out_of_band",                   :default => false
    t.boolean  "use_post_for_authentication_steps", :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "use_xauth",                         :default => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

end
