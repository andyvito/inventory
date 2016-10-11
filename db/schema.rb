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

ActiveRecord::Schema.define(version: 20161010182803) do

  create_table "area_models", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "lead",          limit: 255
    t.integer  "risk_model_id", limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "area_models", ["risk_model_id"], name: "fk_rails_388c24c299", using: :btree

  create_table "backtest_history_models", force: :cascade do |t|
    t.integer  "validate_year",   limit: 4
    t.integer  "validate_month",  limit: 4
    t.integer  "real_year",       limit: 4
    t.integer  "real_month",      limit: 4
    t.integer  "next_year",       limit: 4
    t.integer  "next_month",      limit: 4
    t.integer  "months_delayed",  limit: 4
    t.text     "comentaries",     limit: 65535
    t.boolean  "result"
    t.integer  "model_object_id", limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "backtest_history_models", ["model_object_id"], name: "fk_rails_1a4413d182", using: :btree

  create_table "configurations", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "value",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "model_objects", force: :cascade do |t|
    t.string   "code",                limit: 255
    t.string   "name",                limit: 255
    t.text     "description",         limit: 65535
    t.string   "len",                 limit: 255
    t.string   "cat",                 limit: 255
    t.string   "kind",                limit: 255
    t.integer  "frecuency",           limit: 4
    t.text     "met_validation",      limit: 65535
    t.float    "met_hours_man",       limit: 24
    t.float    "qua_hours_man",       limit: 24
    t.float    "cap_area",            limit: 24
    t.float    "cap_qua",             limit: 24
    t.float    "cap_total",           limit: 24
    t.text     "comments",            limit: 65535
    t.text     "more_info",           limit: 65535
    t.boolean  "curriculum"
    t.string   "file_doc",            limit: 255
    t.string   "version",             limit: 255
    t.boolean  "is_qua"
    t.text     "initial_dates",       limit: 65535
    t.text     "original_author",     limit: 65535
    t.text     "final_dates",         limit: 65535
    t.text     "final_author",        limit: 65535
    t.boolean  "active"
    t.integer  "next_backtest_year",  limit: 4
    t.integer  "next_backtest_month", limit: 4
    t.integer  "risk_model_id",       limit: 4
    t.integer  "area_model_id",       limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "model_objects", ["area_model_id"], name: "fk_rails_160d37d12e", using: :btree
  add_index "model_objects", ["risk_model_id"], name: "fk_rails_fc94b16dc3", using: :btree

  create_table "report_details_months", id: false, force: :cascade do |t|
    t.integer  "report_month_id",           limit: 4, default: 0, null: false
    t.integer  "backtest_history_model_id", limit: 4, default: 0, null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "report_details_months", ["backtest_history_model_id"], name: "fk_rails_ed1fe0c465", using: :btree

  create_table "report_months", force: :cascade do |t|
    t.integer  "year",                 limit: 4
    t.integer  "month",                limit: 4
    t.integer  "total_models",         limit: 4
    t.integer  "total_unvalidated",    limit: 4
    t.integer  "validated",            limit: 4
    t.integer  "validated_fullfil",    limit: 4
    t.integer  "validated_no_fullfil", limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "risk_models", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_foreign_key "area_models", "risk_models"
  add_foreign_key "backtest_history_models", "model_objects"
  add_foreign_key "model_objects", "area_models"
  add_foreign_key "model_objects", "risk_models"
  add_foreign_key "report_details_months", "backtest_history_models"
  add_foreign_key "report_details_months", "report_months"
end
