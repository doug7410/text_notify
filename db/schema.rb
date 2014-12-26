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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141226143352) do

  create_table "account_settings", force: true do |t|
    t.string  "default_add_to_queue_message"
    t.string  "default_send_now_message"
    t.string  "default_send_from_queue_message"
    t.integer "business_owner_id"
    t.string  "message_prefix"
    t.string  "default_message_subject"
  end

  create_table "business_owners", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "company_name"
  end

  add_index "business_owners", ["email"], name: "index_business_owners_on_email", unique: true
  add_index "business_owners", ["reset_password_token"], name: "index_business_owners_on_reset_password_token", unique: true

  create_table "business_owsers", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "business_owsers", ["email"], name: "index_business_owsers_on_email", unique: true
  add_index "business_owsers", ["reset_password_token"], name: "index_business_owsers_on_reset_password_token", unique: true

  create_table "customers", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "business_owner_id"
    t.string   "full_name"
  end

  create_table "group_notifications", force: true do |t|
    t.integer  "group_id"
    t.string   "group_message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "business_owner_id"
  end

  create_table "groups", force: true do |t|
    t.string   "name"
    t.integer  "business_owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memberships", force: true do |t|
    t.integer "customer_id"
    t.integer "group_id"
  end

  create_table "notifications", force: true do |t|
    t.integer  "customer_id"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sid"
    t.datetime "sent_date"
    t.datetime "item_picked_up_date"
    t.integer  "group_notification_id"
    t.string   "status"
    t.string   "error_code"
    t.integer  "business_owner_id"
    t.string   "order_number"
  end

  create_table "queue_items", force: true do |t|
    t.integer  "notification_id"
    t.integer  "business_owner_id"
    t.boolean  "sent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
