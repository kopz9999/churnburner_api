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

ActiveRecord::Schema.define(version: 20160803182344) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "app_tasks", force: :cascade do |t|
    t.integer  "status_identity"
    t.datetime "ran_at"
    t.string   "name"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "companies", force: :cascade do |t|
    t.string   "company_identifier"
    t.string   "name"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "company_data", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "name"
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "intercom_job_sync_events", force: :cascade do |t|
    t.integer  "intercom_job_id"
    t.integer  "sync_event_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "intercom_jobs", force: :cascade do |t|
    t.string   "intercom_id"
    t.integer  "type_identity"
    t.integer  "status_identity"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "segment_users", force: :cascade do |t|
    t.integer  "segment_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "segments", force: :cascade do |t|
    t.string   "intercom_id"
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "sync_events", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "user_id"
    t.integer  "fub_id"
    t.integer  "fub_created"
    t.boolean  "sent_to_intercom",     default: false
    t.boolean  "received_by_intercom", default: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "user_companies", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "intercom_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "name"
    t.integer  "fub_id"
  end

end
