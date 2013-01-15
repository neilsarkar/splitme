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

ActiveRecord::Schema.define(:version => 20130115215753) do

  create_table "commitments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "plan_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "state",      :default => "unpaid", :null => false
    t.string   "debit_uri"
  end

  add_index "commitments", ["plan_id"], :name => "index_commitments_on_plan_id"
  add_index "commitments", ["user_id"], :name => "index_commitments_on_participant_id"

  create_table "participants", :force => true do |t|
    t.string   "name",            :null => false
    t.string   "email",           :null => false
    t.string   "phone_number",    :null => false
    t.string   "card_uri",        :null => false
    t.string   "card_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "buyer_uri"
    t.string   "password_digest"
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
    t.boolean  "locked"
    t.string   "credit_uri"
  end

  add_index "plans", ["token"], :name => "index_plans_on_token", :unique => true
  add_index "plans", ["user_id"], :name => "index_plans_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name",                 :null => false
    t.string   "email",                :null => false
    t.string   "phone_number",         :null => false
    t.string   "token"
    t.string   "password_digest"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "balanced_account_uri"
    t.string   "street_address"
    t.string   "zip_code"
    t.string   "date_of_birth"
    t.string   "card_uri"
    t.string   "bank_account_uri"
  end

  add_index "users", ["token"], :name => "index_users_on_token", :unique => true

end
