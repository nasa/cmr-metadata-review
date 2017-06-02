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

ActiveRecord::Schema.define(version: 20170602153227) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "collections", force: :cascade do |t|
    t.string "concept_id",              null: false
    t.string "short_name", default: ""
  end

  create_table "discussions", force: :cascade do |t|
    t.integer  "record_id",   null: false
    t.integer  "user_id",     null: false
    t.datetime "date",        null: false
    t.string   "column_name", null: false
    t.string   "comment"
  end

  add_index "discussions", ["record_id"], name: "index_discussions_on_record_id", using: :btree
  add_index "discussions", ["user_id"], name: "index_discussions_on_user_id", using: :btree

  create_table "granules", force: :cascade do |t|
    t.string  "concept_id",    null: false
    t.integer "collection_id"
  end

  add_index "granules", ["collection_id"], name: "index_granules_on_collection_id", using: :btree

  create_table "ingests", force: :cascade do |t|
    t.integer  "record_id",     null: false
    t.integer  "user_id",       null: false
    t.datetime "date_ingested", null: false
  end

  add_index "ingests", ["record_id"], name: "index_ingests_on_record_id", using: :btree
  add_index "ingests", ["user_id"], name: "index_ingests_on_user_id", using: :btree

  create_table "record_data", force: :cascade do |t|
    t.integer  "record_id",                      null: false
    t.string   "value",          default: ""
    t.string   "daac",                           null: false
    t.datetime "last_updated"
    t.string   "column_name",                    null: false
    t.string   "color",          default: ""
    t.string   "script_comment", default: ""
    t.boolean  "opinion",        default: false
    t.string   "flag",           default: [],                 array: true
    t.string   "recommendation", default: ""
    t.integer  "order_count",    default: 0
  end

  add_index "record_data", ["record_id"], name: "index_record_data_on_record_id", using: :btree

  create_table "records", force: :cascade do |t|
    t.integer  "recordable_id",                   null: false
    t.string   "recordable_type",                 null: false
    t.string   "revision_id",                     null: false
    t.boolean  "closed",          default: false
    t.datetime "closed_date"
    t.string   "format",          default: ""
  end

  add_index "records", ["recordable_id", "revision_id"], name: "records_recordable_id_revision_id_key", unique: true, using: :btree
  add_index "records", ["recordable_type", "recordable_id"], name: "index_records_on_recordable_type_and_recordable_id", using: :btree

  create_table "records_update_locks", force: :cascade do |t|
    t.datetime "last_update", null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.integer  "record_id",                           null: false
    t.integer  "user_id",                             null: false
    t.datetime "review_completion_date"
    t.integer  "review_state",                        null: false
    t.string   "comment",                default: ""
  end

  add_index "reviews", ["record_id", "user_id"], name: "reviews_record_id_user_id_key", unique: true, using: :btree
  add_index "reviews", ["record_id"], name: "index_reviews_on_record_id", using: :btree
  add_index "reviews", ["user_id"], name: "index_reviews_on_user_id", using: :btree

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
