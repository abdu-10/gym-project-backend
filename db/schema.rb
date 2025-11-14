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

ActiveRecord::Schema[8.1].define(version: 2025_11_14_124010) do
  create_table "memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "plan_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["plan_id"], name: "index_memberships_on_plan_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "plans", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "features"
    t.string "name"
    t.string "period"
    t.boolean "popular"
    t.string "price"
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

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "memberships", "plans"
  add_foreign_key "memberships", "users"
end
