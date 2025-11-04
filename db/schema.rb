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

ActiveRecord::Schema[8.1].define(version: 2025_11_04_230410) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "group_invitations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "group_id", null: false
    t.integer "invited_by_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["created_at"], name: "index_group_invitations_on_created_at"
    t.index ["group_id"], name: "index_group_invitations_on_group_id"
    t.index ["invited_by_id"], name: "index_group_invitations_on_invited_by_id"
    t.index ["status"], name: "index_group_invitations_on_status"
    t.index ["user_id", "group_id", "status"], name: "index_group_invitations_on_user_id_and_group_id_and_status"
    t.index ["user_id", "group_id"], name: "index_group_invitations_on_user_and_group_pending", unique: true, where: "status = 0"
    t.index ["user_id"], name: "index_group_invitations_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "group_id", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_items_on_group_id"
  end

  create_table "list_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "item_id", null: false
    t.integer "list_id", null: false
    t.integer "quantity"
    t.decimal "sort_order"
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_list_items_on_item_id"
    t.index ["list_id"], name: "index_list_items_on_list_id"
  end

  create_table "list_meals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.integer "list_id", null: false
    t.integer "meal_id", null: false
    t.datetime "updated_at", null: false
    t.index ["list_id"], name: "index_list_meals_on_list_id"
    t.index ["meal_id"], name: "index_list_meals_on_meal_id"
  end

  create_table "lists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.integer "group_id", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_lists_on_group_id"
  end

  create_table "meals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "group_id", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_meals_on_group_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.integer "selected_group_id"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["selected_group_id"], name: "index_sessions_on_selected_group_id"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "subscribers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.integer "item_id", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_subscribers_on_item_id"
  end

  create_table "user_group_selections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "group_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["group_id"], name: "index_user_group_selections_on_group_id"
    t.index ["user_id"], name: "index_user_group_selections_on_user_id", unique: true
  end

  create_table "user_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "group_id", null: false
    t.boolean "is_default", default: false, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["group_id"], name: "index_user_groups_on_group_id"
    t.index ["user_id", "group_id"], name: "index_user_groups_on_user_id_and_group_id", unique: true
    t.index ["user_id", "is_default"], name: "index_user_groups_on_user_id_and_is_default_true", unique: true, where: "is_default = true"
    t.index ["user_id"], name: "index_user_groups_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "password_digest", null: false
    t.integer "pending_invitations_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "group_invitations", "groups"
  add_foreign_key "group_invitations", "users"
  add_foreign_key "group_invitations", "users", column: "invited_by_id"
  add_foreign_key "items", "groups"
  add_foreign_key "list_items", "items"
  add_foreign_key "list_items", "lists"
  add_foreign_key "list_meals", "lists"
  add_foreign_key "list_meals", "meals"
  add_foreign_key "lists", "groups"
  add_foreign_key "meals", "groups"
  add_foreign_key "sessions", "groups", column: "selected_group_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "subscribers", "items"
  add_foreign_key "user_group_selections", "groups"
  add_foreign_key "user_group_selections", "users"
  add_foreign_key "user_groups", "groups"
  add_foreign_key "user_groups", "users"
end
