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

ActiveRecord::Schema[8.1].define(version: 2026_02_18_122856) do
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

  create_table "attendances", force: :cascade do |t|
    t.datetime "checked_in_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.integer "class_booking_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["class_booking_id"], name: "index_bookings_on_class_booking_id"
    t.index ["user_id", "class_booking_id"], name: "index_bookings_on_user_id_and_class_booking_id", unique: true
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "class_bookings", force: :cascade do |t|
    t.integer "capacity", default: 20, null: false
    t.string "category"
    t.datetime "created_at", null: false
    t.string "duration"
    t.string "image_url"
    t.string "instructor"
    t.string "name"
    t.string "time"
    t.datetime "updated_at", null: false
  end

  create_table "memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "plan_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["plan_id"], name: "index_memberships_on_plan_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "amount_cents"
    t.datetime "created_at", null: false
    t.string "currency"
    t.string "description"
    t.string "payment_method"
    t.string "status"
    t.string "transaction_id"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "plans", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "features"
    t.string "name"
    t.string "period"
    t.boolean "popular"
    t.string "price"
    t.integer "price_in_cents"
    t.datetime "updated_at", null: false
  end

  create_table "testimonials", force: :cascade do |t|
    t.string "author"
    t.datetime "created_at", null: false
    t.string "image"
    t.string "quote"
    t.integer "rating"
    t.string "role"
    t.datetime "updated_at", null: false
  end

  create_table "trainer_bookings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "goals_message"
    t.date "preferred_date"
    t.time "preferred_time"
    t.string "status"
    t.integer "trainer_id"
    t.string "trainer_name"
    t.datetime "updated_at", null: false
    t.string "user_email"
    t.integer "user_id", null: false
    t.string "user_name"
    t.string "user_phone"
    t.index ["user_id"], name: "index_trainer_bookings_on_user_id"
  end

  create_table "trainers", force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "facebook"
    t.string "image"
    t.string "instagram"
    t.string "name"
    t.string "role"
    t.string "twitter"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.string "qr_token"
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["qr_token"], name: "index_users_on_qr_token"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attendances", "users"
  add_foreign_key "bookings", "class_bookings"
  add_foreign_key "bookings", "users"
  add_foreign_key "memberships", "plans"
  add_foreign_key "memberships", "users"
  add_foreign_key "payments", "users"
  add_foreign_key "trainer_bookings", "trainers"
  add_foreign_key "trainer_bookings", "users"
end
