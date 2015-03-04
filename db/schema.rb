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

ActiveRecord::Schema.define(version: 20150303131731) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authentications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider",     null: false
    t.string   "uid",          null: false
    t.string   "account_name", null: false
    t.string   "url"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "authentications", ["user_id"], name: "index_authentications_on_user_id", using: :btree

  create_table "favorites", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "message_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "favorites", ["message_id"], name: "index_favorites_on_message_id", using: :btree
  add_index "favorites", ["user_id", "message_id"], name: "index_favorites_on_user_id_and_message_id", unique: true, using: :btree
  add_index "favorites", ["user_id"], name: "index_favorites_on_user_id", using: :btree

  create_table "follows", force: :cascade do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "follows", ["followed_id"], name: "index_follows_on_followed_id", using: :btree
  add_index "follows", ["follower_id", "followed_id"], name: "index_follows_on_follower_id_and_followed_id", unique: true, using: :btree
  add_index "follows", ["follower_id"], name: "index_follows_on_follower_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.string   "text",                        null: false
    t.integer  "user_id",                     null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "favorited_count", default: 0, null: false
    t.integer  "retweeted_count", default: 0, null: false
  end

  add_index "messages", ["user_id", "created_at"], name: "index_messages_on_user_id_and_created_at", using: :btree
  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "replies", force: :cascade do |t|
    t.integer  "message_id",    null: false
    t.integer  "to_user_id",    null: false
    t.integer  "to_message_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "replies", ["message_id"], name: "index_replies_on_message_id", using: :btree
  add_index "replies", ["to_message_id"], name: "index_replies_on_to_message_id", using: :btree
  add_index "replies", ["to_user_id"], name: "index_replies_on_to_user_id", using: :btree

  create_table "retweets", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "message_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "retweets", ["message_id"], name: "index_retweets_on_message_id", using: :btree
  add_index "retweets", ["user_id", "message_id"], name: "index_retweets_on_user_id_and_message_id", unique: true, using: :btree
  add_index "retweets", ["user_id"], name: "index_retweets_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                              default: "", null: false
    t.string   "encrypted_password",                 default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "screen_name",                                     null: false
    t.string   "name",                                            null: false
    t.string   "description",            limit: 160
    t.string   "url"
    t.string   "profile_image"
    t.integer  "messages_count",                     default: 0,  null: false
    t.integer  "following_count",                    default: 0,  null: false
    t.integer  "followers_count",                    default: 0,  null: false
    t.integer  "favorites_count",                    default: 0,  null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["screen_name"], name: "index_users_on_screen_name", unique: true, using: :btree

  add_foreign_key "authentications", "users", on_delete: :cascade
  add_foreign_key "favorites", "messages", name: "fk_favorites_message_id", on_delete: :cascade
  add_foreign_key "favorites", "users", name: "fk_favorites_user_id", on_delete: :cascade
  add_foreign_key "follows", "users", column: "followed_id", name: "fk_relationships_followed_id", on_delete: :cascade
  add_foreign_key "follows", "users", column: "follower_id", name: "fk_relationships_follower_id", on_delete: :cascade
  add_foreign_key "messages", "users", name: "fk_messages_user_id", on_delete: :cascade
  add_foreign_key "replies", "messages", column: "to_message_id", name: "fk_replies_to_message_id", on_delete: :cascade
  add_foreign_key "replies", "messages", name: "fk_replies_message_id", on_delete: :cascade
  add_foreign_key "replies", "users", column: "to_user_id", name: "fk_replies_to_user_id", on_delete: :cascade
  add_foreign_key "retweets", "messages", name: "fk_retweets_message_id", on_delete: :cascade
  add_foreign_key "retweets", "users", name: "fk_retweets_user_id", on_delete: :cascade
end
