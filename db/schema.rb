# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_03_090225) do
  create_table "api_clients", force: :cascade do |t|
    t.string "name", null: false
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_api_clients_on_token", unique: true
  end

  create_table "ledger_entries", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "entry_type", null: false
    t.string "key", null: false
    t.json "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "created_at"], name: "index_ledger_entries_on_user_id_and_created_at"
    t.index ["user_id", "key"], name: "index_ledger_entries_user_key", unique: true
    t.index ["user_id"], name: "index_ledger_entries_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "amount_cents", null: false
    t.string "currency", default: "USD", null: false
    t.datetime "occurred_at", null: false
    t.boolean "foreign", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "occurred_at"], name: "index_transactions_on_user_id_and_occurred_at"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.integer "birthday_month", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "birthday_month BETWEEN 1 AND 12", name: "users_birthday_month_1_12"
  end

  add_foreign_key "ledger_entries", "users"
  add_foreign_key "transactions", "users"
end
