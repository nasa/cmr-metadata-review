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

ActiveRecord::Schema.define(version: 20161216202003) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "collection_comments", force: :cascade do |t|
    t.integer "collection_record_id"
    t.integer "user_id"
    t.integer "total_comment_count"
    t.string  "rawJSON"
  end

  add_index "collection_comments", ["collection_record_id"], name: "index_collection_comments_on_collection_record_id", using: :btree
  add_index "collection_comments", ["user_id"], name: "index_collection_comments_on_user_id", using: :btree

  create_table "collection_flags", force: :cascade do |t|
    t.integer "collection_record_id"
    t.integer "user_id"
    t.integer "total_flag_count"
    t.string  "rawJSON"
  end

  add_index "collection_flags", ["collection_record_id"], name: "index_collection_flags_on_collection_record_id", using: :btree
  add_index "collection_flags", ["user_id"], name: "index_collection_flags_on_user_id", using: :btree

  create_table "collection_ingests", force: :cascade do |t|
    t.integer  "collection_record_id"
    t.integer  "user_id"
    t.datetime "date_ingested"
  end

  add_index "collection_ingests", ["collection_record_id"], name: "index_collection_ingests_on_collection_record_id", using: :btree
  add_index "collection_ingests", ["user_id"], name: "index_collection_ingests_on_user_id", using: :btree

  create_table "collection_records", force: :cascade do |t|
    t.string  "concept_id",              null: false
    t.string  "short_name", default: ""
    t.float   "version_id"
    t.boolean "closed"
    t.string  "rawJSON"
  end

  create_table "collection_reviews", force: :cascade do |t|
    t.integer  "collection_record_id"
    t.integer  "user_id"
    t.datetime "review_completion_date"
    t.integer  "review_state"
  end

  add_index "collection_reviews", ["collection_record_id"], name: "index_collection_reviews_on_collection_record_id", using: :btree
  add_index "collection_reviews", ["user_id"], name: "index_collection_reviews_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "admin",                  default: false
    t.boolean  "curator",                default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
