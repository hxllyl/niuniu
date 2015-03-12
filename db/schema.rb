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

ActiveRecord::Schema.define(version: 20150311091518) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "areas", force: :cascade do |t|
    t.string   "name",         limit: 20, null: false
    t.integer  "level"
    t.integer  "parent_id_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "base_cars", force: :cascade do |t|
    t.decimal  "base_price",             precision: 10, scale: 2
    t.integer  "brand_id_id"
    t.string   "outer_color", limit: 20
    t.string   "model",       limit: 30,                          null: false
    t.string   "inner_color", limit: 20
    t.integer  "standard"
    t.string   "style",       limit: 60
    t.string   "NO",          limit: 12
    t.integer  "status"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  create_table "brands", force: :cascade do |t|
    t.string   "name",       limit: 40, null: false
    t.integer  "status"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id_id"
    t.integer  "resource_id"
    t.string   "resource_type", limit: 30
    t.string   "content",       limit: 225, null: false
    t.integer  "parent_id_id"
    t.integer  "status"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "companies", force: :cascade do |t|
    t.string   "name",       limit: 225, null: false
    t.integer  "area_id_id"
    t.integer  "status"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "complaints", force: :cascade do |t|
    t.integer  "resource_id"
    t.string   "resource_type", limit: 30
    t.integer  "user_id_id"
    t.integer  "status"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "follow_ships", force: :cascade do |t|
    t.integer  "follower_id_id"
    t.integer  "following_id_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "history_lists", force: :cascade do |t|
    t.integer  "user_id_id"
    t.integer  "resource_id"
    t.string   "resource_type", limit: 30
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "nodifications", force: :cascade do |t|
    t.integer  "user_id_id"
    t.string   "content",       limit: 225
    t.integer  "status"
    t.integer  "resource_id"
    t.string   "resource_type", limit: 30
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "photos", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "owner_type", limit: 20
    t.string   "image",      limit: 60
    t.string   "_type",      limit: 30
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "posts", force: :cascade do |t|
    t.integer  "user_id_id"
    t.integer  "_type"
    t.integer  "brand_id_id"
    t.string   "remark",            limit: 160
    t.integer  "base_car_id_id"
    t.integer  "standard",                                                           null: false
    t.string   "model",             limit: 40,                                       null: false
    t.string   "style",             limit: 60
    t.string   "outer_color",       limit: 20,                                       null: false
    t.string   "inner_color",       limit: 20,                                       null: false
    t.string   "car_license_areas", limit: 60,                                       null: false
    t.string   "car_in_areas",      limit: 60,                                       null: false
    t.integer  "take_car_date",                                          default: 0
    t.decimal  "expect_price",                  precision: 10, scale: 2
    t.integer  "discouts_way",                                                       null: false
    t.decimal  "discounts_content",             precision: 10, scale: 2
    t.integer  "status"
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
  end

  create_table "tenders", force: :cascade do |t|
    t.integer  "post_id_id"
    t.integer  "user_id_id"
    t.decimal  "price",      precision: 10, scale: 2
    t.integer  "status"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "tokens", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "value",      limit: 50, null: false
    t.datetime "expired_at"
    t.integer  "status"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                   limit: 15,               null: false
    t.string   "mobile",                 limit: 15,               null: false
    t.integer  "_type"
    t.string   "company",                limit: 225
    t.string   "role",                   limit: 30
    t.integer  "area_id_id"
    t.integer  "level",                              default: 0
    t.integer  "status",                             default: 0
    t.string   "salt",                   limit: 45,               null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "email",                              default: "", null: false
    t.string   "encrypted_password",                 default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "valid_codes", force: :cascade do |t|
    t.string   "mobile",     limit: 15, null: false
    t.string   "code",       limit: 10, null: false
    t.integer  "_type"
    t.integer  "status"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

end
