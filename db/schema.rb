# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_03_15_150210) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cmr_syncs", force: :cascade do |t|
    t.datetime "updated_since"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "collections", id: :serial, force: :cascade do |t|
    t.string "concept_id", null: false
    t.string "short_name", default: ""
    t.boolean "cmr_update", default: true
  end

  create_table "discussions", id: :serial, force: :cascade do |t|
    t.integer "record_id", null: false
    t.integer "user_id", null: false
    t.datetime "date", null: false
    t.string "column_name", null: false
    t.string "comment"
    t.integer "category", default: 0
    t.index ["record_id"], name: "index_discussions_on_record_id"
    t.index ["user_id"], name: "index_discussions_on_user_id"
  end

  create_table "granules", id: :serial, force: :cascade do |t|
    t.string "concept_id", null: false
    t.integer "collection_id"
    t.string "latest_revision_in_cmr"
    t.boolean "deleted_in_cmr"
    t.index ["collection_id"], name: "index_granules_on_collection_id"
  end

  create_table "ingests", id: :serial, force: :cascade do |t|
    t.integer "record_id", null: false
    t.integer "user_id", null: false
    t.datetime "date_ingested", null: false
    t.index ["record_id"], name: "index_ingests_on_record_id"
    t.index ["user_id"], name: "index_ingests_on_user_id"
  end

  create_table "invalid_keywords", force: :cascade do |t|
    t.string "provider_id"
    t.string "concept_id"
    t.integer "revision_id"
    t.string "short_name"
    t.string "version"
    t.string "invalid_keyword_path"
    t.string "valid_keyword_path"
    t.string "ummc_field"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "scheme"
  end

  create_table "record_data", id: :serial, force: :cascade do |t|
    t.integer "record_id", null: false
    t.string "value", default: ""
    t.datetime "last_updated"
    t.string "column_name", null: false
    t.string "color", default: ""
    t.string "script_comment", default: ""
    t.boolean "opinion", default: false
    t.string "flag", default: [], array: true
    t.string "recommendation", default: ""
    t.integer "order_count", default: 0
    t.boolean "feedback", default: false
    t.index ["column_name"], name: "index_record_data_on_column_name"
    t.index ["record_id"], name: "index_record_data_on_record_id"
  end

  create_table "records", id: :serial, force: :cascade do |t|
    t.string "recordable_type", null: false
    t.integer "recordable_id", null: false
    t.string "revision_id", null: false
    t.datetime "closed_date"
    t.string "format", default: ""
    t.string "state"
    t.string "associated_granule_value"
    t.string "copy_recommendations_note"
    t.datetime "released_to_daac_date"
    t.string "daac"
    t.string "campaign", default: [], null: false, array: true
    t.string "native_format"
    t.index ["recordable_type", "recordable_id"], name: "index_records_on_recordable_type_and_recordable_id"
  end

  create_table "records_update_locks", id: :serial, force: :cascade do |t|
    t.datetime "last_update", null: false
  end

  create_table "reviews", id: :serial, force: :cascade do |t|
    t.integer "record_id", null: false
    t.integer "user_id", null: false
    t.datetime "review_completion_date"
    t.integer "review_state", null: false
    t.string "review_comment", default: ""
    t.string "report_comment", default: ""
    t.index ["record_id", "user_id"], name: "reviews_record_id_user_id_key", unique: true
    t.index ["record_id"], name: "index_reviews_on_record_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "sessions", id: :serial, force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
    t.string "daac"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "provider"
    t.string "uid"
    t.string "access_token"
    t.string "refresh_token"
    t.string "name"
    t.string "email_preference"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

end
