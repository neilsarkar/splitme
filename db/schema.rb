# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20121014204146) do

  create_table "commitments", :force => true do |t|
    t.integer  "participant_id"
    t.integer  "plan_id"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "state",          :default => "unpaid", :null => false
  end

  add_index "commitments", ["participant_id"], :name => "index_commitments_on_participant_id"
  add_index "commitments", ["plan_id"], :name => "index_commitments_on_plan_id"

  create_table "participants", :force => true do |t|
    t.string   "name",         :null => false
    t.string   "email",        :null => false
    t.string   "phone_number", :null => false
    t.string   "card_uri",     :null => false
    t.string   "card_type"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "buyer_uri"
  end

  create_table "plans", :force => true do |t|
    t.string   "title",            :null => false
    t.text     "description"
    t.integer  "total_price"
    t.integer  "price_per_person"
    t.integer  "user_id",          :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "token"
  end

  add_index "plans", ["token"], :name => "index_plans_on_token", :unique => true
  add_index "plans", ["user_id"], :name => "index_plans_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name",                 :null => false
    t.string   "email",                :null => false
    t.string   "phone_number",         :null => false
    t.string   "bank_routing_number",  :null => false
    t.string   "bank_account_number",  :null => false
    t.string   "token"
    t.string   "password_digest"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "balanced_payments_id"
    t.string   "street_address"
    t.string   "zip_code"
    t.string   "date_of_birth"
  end

  add_index "users", ["token"], :name => "index_users_on_token", :unique => true

end
