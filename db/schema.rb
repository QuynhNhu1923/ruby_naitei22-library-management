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

ActiveRecord::Schema[7.0].define(version: 2025_08_09_155933) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "authors", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "bio"
    t.date "birth_date"
    t.date "death_date"
    t.string "nationality", limit: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "book_categories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.bigint "category_id", null: false
    t.index ["book_id", "category_id"], name: "index_book_categories_on_book_id_and_category_id", unique: true
    t.index ["book_id"], name: "index_book_categories_on_book_id"
    t.index ["category_id"], name: "index_book_categories_on_category_id"
  end

  create_table "books", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "publication_year"
    t.integer "total_quantity", default: 0, null: false
    t.integer "available_quantity", default: 0, null: false
    t.integer "borrow_count", default: 0, null: false
    t.bigint "author_id", null: false
    t.bigint "publisher_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_books_on_author_id"
    t.index ["publisher_id"], name: "index_books_on_publisher_id"
    t.index ["title"], name: "index_books_on_title"
  end

  create_table "borrow_request_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "borrow_request_id", null: false
    t.bigint "book_id", null: false
    t.integer "quantity", default: 1, null: false
    t.index ["book_id"], name: "index_borrow_request_items_on_book_id"
    t.index ["borrow_request_id", "book_id"], name: "index_borrow_request_items_on_borrow_request_id_and_book_id", unique: true
    t.index ["borrow_request_id"], name: "index_borrow_request_items_on_borrow_request_id"
  end

  create_table "borrow_requests", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "request_date", null: false
    t.integer "status", default: 0, null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.date "actual_return_date"
    t.text "admin_note"
    t.bigint "approved_by_admin_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rejected_by_admin_id"
    t.integer "returned_by_admin_id"
    t.index ["approved_by_admin_id"], name: "index_borrow_requests_on_approved_by_admin_id"
    t.index ["status"], name: "index_borrow_requests_on_status"
    t.index ["user_id"], name: "index_borrow_requests_on_user_id"
  end

  create_table "categories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "favorites", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "favorable_type", null: false
    t.bigint "favorable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["favorable_id", "favorable_type"], name: "index_favorites_on_favorable_id_and_favorable_type"
    t.index ["favorable_type", "favorable_id"], name: "index_favorites_on_favorable"
    t.index ["user_id", "favorable_id", "favorable_type"], name: "index_favorites_on_user_and_favorable", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "publishers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "address"
    t.string "phone_number", limit: 20
    t.string "email"
    t.string "website"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_publishers_on_name", unique: true
  end

  create_table "reviews", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "book_id", null: false
    t.integer "score", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_reviews_on_book_id"
    t.index ["user_id", "book_id"], name: "index_reviews_on_user_id_and_book_id", unique: true
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.integer "gender", null: false
    t.date "date_of_birth", null: false
    t.integer "status", default: 0, null: false
    t.string "phone_number", limit: 20
    t.string "address"
    t.string "activation_token"
    t.datetime "activated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remember_digest"
    t.string "reset_digest"
    t.string "activation_digest"
    t.string "provider"
    t.string "uid"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["remember_digest"], name: "index_users_on_remember_digest"
    t.index ["reset_digest"], name: "index_users_on_reset_digest"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "book_categories", "books"
  add_foreign_key "book_categories", "categories"
  add_foreign_key "books", "authors"
  add_foreign_key "books", "publishers"
  add_foreign_key "borrow_request_items", "books"
  add_foreign_key "borrow_request_items", "borrow_requests"
  add_foreign_key "borrow_requests", "users"
  add_foreign_key "borrow_requests", "users", column: "approved_by_admin_id"
  add_foreign_key "favorites", "users"
  add_foreign_key "reviews", "books"
  add_foreign_key "reviews", "users"
end
