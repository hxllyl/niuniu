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

ActiveRecord::Schema.define(version: 20150411131821) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_devices", force: :cascade do |t|
    t.integer  "user_id",                                null: false
    t.string   "register_id", limit: 30,                 null: false
    t.boolean  "active",                 default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "active_devices", ["register_id"], name: "index_active_devices_on_register_id", using: :btree
  add_index "active_devices", ["user_id"], name: "index_active_devices_on_user_id", using: :btree

  create_table "areas", force: :cascade do |t|
    t.string   "name",       limit: 20, null: false
    t.integer  "level"
    t.integer  "parent_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "areas", ["name"], name: "index_areas_on_name", using: :btree
  add_index "areas", ["parent_id"], name: "index_areas_on_parent_id", using: :btree

  create_table "banners", force: :cascade do |t|
    t.string   "title"
    t.string   "poi"
    t.string   "position"
    t.string   "image"
    t.datetime "begin_at"
    t.datetime "end_at"
    t.string   "use"
    t.string   "redirect_way"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "base_cars", force: :cascade do |t|
    t.integer  "standard_id",                                                    null: false
    t.integer  "brand_id",                                                       null: false
    t.integer  "car_model_id",                                                   null: false
    t.decimal  "base_price",              precision: 10, scale: 2, default: 0.0
    t.string   "outer_color",                                                                 array: true
    t.string   "inner_color",                                                                 array: true
    t.string   "style",        limit: 60
    t.string   "NO",           limit: 12,                          default: ""
    t.integer  "status",                                           default: 1
    t.string   "display_name"
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
  end

  add_index "base_cars", ["NO"], name: "index_base_cars_on_NO", using: :btree
  add_index "base_cars", ["base_price"], name: "index_base_cars_on_base_price", using: :btree
  add_index "base_cars", ["brand_id"], name: "index_base_cars_on_brand_id", using: :btree
  add_index "base_cars", ["car_model_id"], name: "index_base_cars_on_car_model_id", using: :btree
  add_index "base_cars", ["outer_color", "inner_color"], name: "index_base_cars_on_outer_color_and_inner_color", using: :btree
  add_index "base_cars", ["standard_id"], name: "index_base_cars_on_standard_id", using: :btree
  add_index "base_cars", ["style"], name: "index_base_cars_on_style", using: :btree

  create_table "brands", force: :cascade do |t|
    t.string   "name",          limit: 40,             null: false
    t.string   "regions",                                           array: true
    t.integer  "status",                   default: 0
    t.integer  "click_counter",            default: 0
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "brands", ["name"], name: "index_brands_on_name", using: :btree

  create_table "brands_standards", id: false, force: :cascade do |t|
    t.integer "brand_id",    null: false
    t.integer "standard_id", null: false
  end

  add_index "brands_standards", ["brand_id"], name: "index_brands_standards_on_brand_id", using: :btree
  add_index "brands_standards", ["standard_id"], name: "index_brands_standards_on_standard_id", using: :btree

  create_table "car_models", force: :cascade do |t|
    t.integer  "standard_id",               null: false
    t.integer  "brand_id",                  null: false
    t.string   "name",                      null: false
    t.string   "display_name"
    t.integer  "status",        default: 1
    t.integer  "click_counter", default: 0
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "car_models", ["brand_id"], name: "index_car_models_on_brand_id", using: :btree
  add_index "car_models", ["standard_id"], name: "index_car_models_on_standard_id", using: :btree
  add_index "car_models", ["status"], name: "index_car_models_on_status", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "resource_id"
    t.string   "resource_type", limit: 30
    t.string   "content",       limit: 225,             null: false
    t.integer  "parent_id"
    t.integer  "status",                    default: 0
    t.string   "ancestry"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "comments", ["ancestry"], name: "index_comments_on_ancestry", using: :btree
  add_index "comments", ["content"], name: "index_comments_on_content", using: :btree
  add_index "comments", ["resource_id", "resource_type"], name: "index_comments_on_resource_id_and_resource_type", using: :btree
  add_index "comments", ["status"], name: "index_comments_on_status", using: :btree

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
    t.integer  "user_id",                               null: false
    t.integer  "status",                    default: 0
    t.string   "content",       limit: 225
    t.integer  "operator_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "complaints", ["operator_id"], name: "index_complaints_on_operator_id", using: :btree
  add_index "complaints", ["resource_id", "resource_type"], name: "index_complaints_on_resource_id_and_resource_type", using: :btree
  add_index "complaints", ["user_id"], name: "index_complaints_on_user_id", using: :btree

  create_table "follow_ships", force: :cascade do |t|
    t.integer  "follower_id",  null: false
    t.integer  "following_id", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "follow_ships", ["follower_id"], name: "index_follow_ships_on_follower_id", using: :btree
  add_index "follow_ships", ["following_id"], name: "index_follow_ships_on_following_id", using: :btree

  create_table "helpers", force: :cascade do |t|
    t.string   "title"
    t.string   "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "log_base_cars", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "base_car_id"
    t.string   "method_name", null: false
    t.string   "content",     null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "log_base_cars", ["base_car_id"], name: "index_log_base_cars_on_base_car_id", using: :btree
  add_index "log_base_cars", ["method_name"], name: "index_log_base_cars_on_method_name", using: :btree
  add_index "log_base_cars", ["user_id"], name: "index_log_base_cars_on_user_id", using: :btree

  create_table "log_contact_phones", force: :cascade do |t|
    t.string   "mobile",          limit: 15,                 null: false
    t.integer  "sender_id"
    t.integer  "_type",                      default: 0
    t.boolean  "is_register",                default: false
    t.integer  "reg_admin_id"
    t.datetime "last_contact_at"
    t.integer  "status"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "log_contact_phones", ["_type"], name: "index_log_contact_phones_on__type", using: :btree
  add_index "log_contact_phones", ["mobile"], name: "index_log_contact_phones_on_mobile", using: :btree

  create_table "log_posts", force: :cascade do |t|
    t.integer  "user_id",                     null: false
    t.integer  "post_id",                     null: false
    t.string   "method_name"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "read",        default: false
  end

  add_index "log_posts", ["method_name"], name: "index_log_posts_on_method_name", using: :btree
  add_index "log_posts", ["post_id"], name: "index_log_posts_on_post_id", using: :btree
  add_index "log_posts", ["user_id"], name: "index_log_posts_on_user_id", using: :btree

  create_table "log_user_update_levels", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "operator_id"
    t.string   "method_name", limit: 20, default: "update_level"
    t.integer  "start_level"
    t.integer  "end_level"
    t.integer  "status",                 default: 0
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "log_user_update_levels", ["end_level"], name: "index_log_user_update_levels_on_end_level", using: :btree
  add_index "log_user_update_levels", ["method_name"], name: "index_log_user_update_levels_on_method_name", using: :btree
  add_index "log_user_update_levels", ["status"], name: "index_log_user_update_levels_on_status", using: :btree
  add_index "log_user_update_levels", ["user_id"], name: "index_log_user_update_levels_on_user_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.string   "title",          limit: 100
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.integer  "_type",                      default: 0
    t.string   "content",                                null: false
    t.integer  "status",                     default: 0
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "receiver_group"
    t.string   "mask",           limit: 15
  end

  add_index "messages", ["_type"], name: "index_messages_on__type", using: :btree
  add_index "messages", ["receiver_id"], name: "index_messages_on_receiver_id", using: :btree
  add_index "messages", ["sender_id"], name: "index_messages_on_sender_id", using: :btree
  add_index "messages", ["status"], name: "index_messages_on_status", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id",                               null: false
    t.string   "content",       limit: 225
    t.integer  "status",                    default: 0
    t.integer  "resource_id"
    t.string   "resource_type", limit: 30
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "notifications", ["resource_id", "resource_type"], name: "index_notifications_on_resource_id_and_resource_type", using: :btree
  add_index "notifications", ["status"], name: "index_notifications_on_status", using: :btree
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "photos", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "owner_type", limit: 20
    t.string   "image",      limit: 60
    t.string   "_type",      limit: 30
    t.string   "mask",       limit: 10
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "photos", ["_type"], name: "index_photos_on__type", using: :btree
  add_index "photos", ["owner_id", "owner_type"], name: "index_photos_on_owner_id_and_owner_type", using: :btree

  create_table "posts", force: :cascade do |t|
    t.integer  "standard_id",                                                        null: false
    t.integer  "brand_id",                                                           null: false
    t.integer  "car_model_id",                                                       null: false
    t.integer  "base_car_id",                                                        null: false
    t.integer  "user_id",                                                            null: false
    t.integer  "_type"
    t.text     "remark"
    t.string   "outer_color",      limit: 60,                                        null: false
    t.string   "inner_color",      limit: 60,                                        null: false
    t.string   "car_license_area", limit: 60,                                        null: false
    t.string   "car_in_area"
    t.integer  "take_car_date",                                        default: 0
    t.decimal  "expect_price",                precision: 10, scale: 2, default: 0.0
    t.integer  "discount_way",                                                       null: false
    t.decimal  "discount_content",            precision: 10, scale: 2, default: 0.0
    t.integer  "status",                                               default: 1
    t.integer  "resource_type",                                                      null: false
    t.integer  "sys_set_count",                                        default: 0
    t.integer  "channel",                                              default: 0
    t.integer  "position"
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
  end

  add_index "posts", ["_type"], name: "index_posts_on__type", using: :btree
  add_index "posts", ["base_car_id"], name: "index_posts_on_base_car_id", using: :btree
  add_index "posts", ["brand_id"], name: "index_posts_on_brand_id", using: :btree
  add_index "posts", ["expect_price"], name: "index_posts_on_expect_price", using: :btree
  add_index "posts", ["outer_color", "inner_color"], name: "index_posts_on_outer_color_and_inner_color", using: :btree
  add_index "posts", ["standard_id"], name: "index_posts_on_standard_id", using: :btree
  add_index "posts", ["status"], name: "index_posts_on_status", using: :btree
  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "standards", force: :cascade do |t|
    t.string   "name",       limit: 15, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "standards", ["name"], name: "index_standards_on_name", using: :btree

  create_table "tenders", force: :cascade do |t|
    t.integer  "post_id",                                                 null: false
    t.integer  "user_id",                                                 null: false
    t.decimal  "price",            precision: 10, scale: 2, default: 0.0
    t.integer  "discount_way",                                            null: false
    t.decimal  "discount_content", precision: 10, scale: 2, default: 0.0
    t.integer  "status",                                    default: 0
    t.text     "remark"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
  end

  add_index "tenders", ["post_id"], name: "index_tenders_on_post_id", using: :btree
  add_index "tenders", ["price"], name: "index_tenders_on_price", using: :btree
  add_index "tenders", ["status"], name: "index_tenders_on_status", using: :btree
  add_index "tenders", ["user_id"], name: "index_tenders_on_user_id", using: :btree

  create_table "tokens", force: :cascade do |t|
    t.integer  "user_id",                           null: false
    t.string   "value",      limit: 50,             null: false
    t.datetime "expired_at"
    t.integer  "status",                default: 0
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "tokens", ["user_id"], name: "index_tokens_on_user_id", using: :btree
  add_index "tokens", ["value"], name: "index_tokens_on_value", using: :btree

  create_table "user_messages", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "message_id"
    t.integer  "status",     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_messages", ["message_id"], name: "index_user_messages_on_message_id", using: :btree
  add_index "user_messages", ["user_id"], name: "index_user_messages_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                   limit: 15,                     null: false
    t.string   "mobile",                 limit: 15,                     null: false
    t.integer  "_type"
    t.string   "company",                limit: 225
    t.string   "role",                   limit: 30,  default: "normal"
    t.integer  "reg_status",                         default: 0
    t.integer  "area_id",                                               null: false
    t.integer  "level",                              default: 0
    t.integer  "status",                             default: 0
    t.jsonb    "contact",                            default: {}
    t.string   "job_number",             limit: 15
    t.integer  "customer_service_id"
    t.string   "mask",                   limit: 10
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.string   "email",                              default: ""
    t.string   "encrypted_password",                 default: "",       null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,        null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
  end

  add_index "users", ["area_id"], name: "index_users_on_area_id", using: :btree
  add_index "users", ["job_number"], name: "index_users_on_job_number", using: :btree
  add_index "users", ["level"], name: "index_users_on_level", using: :btree
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

  add_index "valid_codes", ["_type"], name: "index_valid_codes_on__type", using: :btree
  add_index "valid_codes", ["code"], name: "index_valid_codes_on_code", using: :btree
  add_index "valid_codes", ["mobile"], name: "index_valid_codes_on_mobile", using: :btree
  add_index "valid_codes", ["status"], name: "index_valid_codes_on_status", using: :btree

end
