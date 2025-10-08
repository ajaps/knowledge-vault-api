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

ActiveRecord::Schema[8.0].define(version: 2025_10_07_232791) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "documents", force: :cascade do |t|
    t.string "title", null: false
    t.bigint "vault_id", null: false
    t.string "file_path", null: false
    t.string "content_type"
    t.integer "file_size"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["metadata"], name: "index_documents_on_metadata", using: :gin
    t.index ["vault_id"], name: "index_documents_on_vault"
    t.index ["vault_id"], name: "index_documents_on_vault_id"
  end

  create_table "shared_api_keys", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "key", null: false
    t.boolean "active", default: true
    t.datetime "last_used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_shared_api_keys_on_key", unique: true
    t.index ["user_id", "active"], name: "index_shared_api_keys_on_user_id_and_active"
    t.index ["user_id"], name: "index_shared_api_keys_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "name", null: false
    t.string "owner_api_key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["owner_api_key"], name: "index_users_on_owner_api_key", unique: true
  end

  create_table "vaults", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_vaults_on_user"
    t.index ["user_id"], name: "index_vaults_on_user_id"
  end

  add_foreign_key "documents", "vaults"
  add_foreign_key "shared_api_keys", "users"
  add_foreign_key "vaults", "users"
end
