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

ActiveRecord::Schema.define(version: 20170426191451) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "collections", force: :cascade do |t|
    t.string "concept_id",              null: false
    t.string "short_name", default: ""
  end

  add_index "collections", ["concept_id"], name: "collections_concept_id_key", unique: true, using: :btree
  add_index "collections", ["concept_id"], name: "index_collections_on_concept_id", using: :btree

  create_table "discussions", force: :cascade do |t|
    t.integer  "record_id"
    t.integer  "user_id"
    t.datetime "date"
    t.string   "column_name"
    t.string   "comment"
  end

  add_index "discussions", ["record_id"], name: "index_discussions_on_record_id", using: :btree
  add_index "discussions", ["user_id"], name: "index_discussions_on_user_id", using: :btree

  create_table "granules", force: :cascade do |t|
    t.string  "concept_id"
    t.integer "collection_id"
  end

  add_index "granules", ["collection_id"], name: "index_granules_on_collection_id", using: :btree
  add_index "granules", ["concept_id"], name: "granules_concept_id_key", unique: true, using: :btree

  create_table "ingests", force: :cascade do |t|
    t.integer  "record_id"
    t.integer  "user_id"
    t.datetime "date_ingested"
  end

  add_index "ingests", ["record_id"], name: "index_ingests_on_record_id", using: :btree
  add_index "ingests", ["user_id"], name: "index_ingests_on_user_id", using: :btree

  create_table "record_data", force: :cascade do |t|
    t.integer  "record_id"
    t.string   "value",          default: ""
    t.string   "daac"
    t.datetime "last_updated"
    t.string   "column_name"
    t.string   "color",          default: ""
    t.string   "script_comment", default: ""
    t.boolean  "opinion",        default: false
    t.string   "flag",           default: [],    array: true
    t.string   "recommendation", default: ""
  end

  add_index "record_data", ["record_id"], name: "index_record_data_on_record_id", using: :btree

  create_table "records", force: :cascade do |t|
    t.integer  "recordable_id"
    t.string   "recordable_type"
    t.string   "revision_id"
    t.boolean  "closed"
    t.datetime "closed_date"
  end

  add_index "records", ["recordable_id", "revision_id"], name: "records_recordable_id_revision_id_key", unique: true, using: :btree
  add_index "records", ["recordable_type", "recordable_id"], name: "index_records_on_recordable_type_and_recordable_id", using: :btree

  create_table "records_update_locks", force: :cascade do |t|
    t.datetime "last_update"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer  "record_id"
    t.integer  "user_id"
    t.datetime "review_completion_date"
    t.integer  "review_state"
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
