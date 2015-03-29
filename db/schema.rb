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

ActiveRecord::Schema.define(version: 20150326094131) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "areas", force: :cascade do |t|
    t.string   "name",       limit: 20, null: false
    t.integer  "level"
    t.integer  "parent_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "base_cars", force: :cascade do |t|
    t.integer  "standard_id"
    t.integer  "brand_id"
    t.integer  "car_model_id"
    t.decimal  "base_price",              precision: 10, scale: 2
    t.string   "outer_color",                                                                array: true
    t.string   "inner_color",                                                                array: true
    t.string   "style",        limit: 60
    t.string   "NO",           limit: 12,                          default: ""
    t.integer  "status",                                           default: 1
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
  end

  add_index "base_cars", ["style", "NO"], name: "index_base_cars_on_style_and_NO", using: :btree

  create_table "brands", force: :cascade do |t|
    t.integer  "standard_id"
    t.string   "name",          limit: 40,             null: false
    t.string   "regions",                                           array: true
    t.integer  "status",                   default: 0
    t.integer  "click_counter",            default: 0
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "brands_standards", id: false, force: :cascade do |t|
    t.integer "brand_id"
    t.integer "standard_id"
  end

  create_table "car_models", force: :cascade do |t|
    t.integer  "standard_id"
    t.integer  "brand_id"
    t.string   "name",                      null: false
    t.integer  "status",        default: 1
    t.integer  "click_counter", default: 0
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "resource_id"
    t.string   "resource_type", limit: 30
    t.string   "content",       limit: 225,             null: false
    t.integer  "parent_id"
    t.integer  "status",                    default: 0
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "companies", force: :cascade do |t|
    t.string   "name",       limit: 225,             null: false
    t.integer  "area_id"
    t.integer  "status",                 default: 0
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "complaints", force: :cascade do |t|
    t.integer  "resource_id"
    t.string   "resource_type", limit: 30
    t.integer  "user_id"
    t.integer  "status",                    default: 0
    t.string   "content",       limit: 225
    t.integer  "operator_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "follow_ships", force: :cascade do |t|
    t.integer  "follower_id"
    t.integer  "following_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "log_posts", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.string   "method_name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "messages", force: :cascade do |t|
    t.string   "title",       limit: 100
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.integer  "_type",                   default: 0
    t.string   "content",                             null: false
    t.integer  "status",                  default: 0
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "content",       limit: 225
    t.integer  "status",                    default: 0
    t.integer  "resource_id"
    t.string   "resource_type", limit: 30
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "photos", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "owner_type", limit: 20
    t.string   "image",      limit: 60
    t.string   "_type",      limit: 30
    t.string   "mask",       limit: 10
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "posts", force: :cascade do |t|
    t.integer  "standard_id"
    t.integer  "brand_id"
    t.integer  "car_model_id"
    t.integer  "base_car_id"
    t.integer  "user_id"
    t.integer  "_type"
    t.string   "remark",            limit: 160
    t.string   "outer_color",       limit: 60,                                        null: false
    t.string   "inner_color",       limit: 60,                                        null: false
    t.string   "car_license_areas", limit: 60,                                        null: false
    t.string   "car_in_areas",                                           default: [], null: false, array: true
    t.integer  "take_car_date",                                          default: 0
    t.decimal  "expect_price",                  precision: 10, scale: 2
    t.integer  "discount_way",                                                        null: false
    t.decimal  "discount_content",              precision: 10, scale: 2
    t.integer  "status",                                                 default: 1
    t.integer  "resource_type",                                                       null: false
    t.integer  "sys_set_count",                                          default: 0
    t.integer  "channel",                                                default: 0
    t.integer  "position"
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
  end

  create_table "standards", force: :cascade do |t|
    t.string   "name",       limit: 15, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "tenders", force: :cascade do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.decimal  "price",            precision: 10, scale: 2
    t.integer  "discount_way",                                          null: false
    t.decimal  "discount_content", precision: 10, scale: 2
    t.integer  "status",                                    default: 0
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  create_table "tokens", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "value",      limit: 50,             null: false
    t.datetime "expired_at"
    t.integer  "status",                default: 0
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                   limit: 15,               null: false
    t.string   "mobile",                 limit: 15,               null: false
    t.integer  "_type"
    t.string   "company",                limit: 225
    t.string   "role",                   limit: 30
    t.integer  "area_id"
    t.integer  "level",                              default: 0
    t.integer  "status",                             default: 0
    t.jsonb    "contact",                            default: {}
    t.string   "job_number",             limit: 15
    t.integer  "customer_service_id"
    t.string   "mask",                   limit: 10
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "email",                              default: ""
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

  add_index "users", ["mobile"], name: "index_users_on_mobile", unique: true, using: :btree
  add_index "users", ["name"], name: "index_users_on_name", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "valid_codes", force: :cascade do |t|
    t.string   "mobile",     limit: 15,             null: false
    t.string   "code",       limit: 10,             null: false
    t.integer  "_type"
    t.integer  "status",                default: 0
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

end
