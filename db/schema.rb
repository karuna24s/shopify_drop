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

ActiveRecord::Schema[7.2].define(version: 2026_01_06_164014) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "claims", force: :cascade do |t|
    t.integer "user_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_claims_on_product_id"
    t.index ["user_id"], name: "index_claims_on_user_id", unique: true
    t.index ["user_id"], name: "index_claims_on_user_id_unique", unique: true
  end

  create_table "order_events", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "from_status", null: false
    t.string "to_status", null: false
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_status"], name: "index_order_events_on_from_status"
    t.index ["order_id"], name: "index_order_events_on_order_id"
    t.index ["to_status"], name: "index_order_events_on_to_status"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_orders_on_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.integer "inventory_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "inventory_count >= 0", name: "inventory_min_zero"
  end

  create_table "restock_notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "product_id", null: false
    t.datetime "notified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_restock_notifications_on_product_id"
    t.index ["user_id", "product_id"], name: "index_restock_notifications_on_user_id_and_product_id", unique: true
    t.index ["user_id"], name: "index_restock_notifications_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.boolean "vip", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "claims", "products"
  add_foreign_key "claims", "users"
  add_foreign_key "order_events", "orders"
  add_foreign_key "orders", "users"
  add_foreign_key "restock_notifications", "products"
  add_foreign_key "restock_notifications", "users"
end
