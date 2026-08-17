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

ActiveRecord::Schema[8.1].define(version: 2026_08_17_030000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "pg_catalog.plpgsql"

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

  create_table "booking_documents", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.datetime "created_at", null: false
    t.integer "document_type", default: 0, null: false
    t.date "due_on"
    t.string "google_drive_file_id"
    t.string "google_drive_url"
    t.string "name", null: false
    t.text "notes"
    t.date "signed_on"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "uploaded_by_id"
    t.index ["booking_id"], name: "index_booking_documents_on_booking_id"
    t.index ["document_type"], name: "index_booking_documents_on_document_type"
    t.index ["google_drive_file_id"], name: "index_booking_documents_on_google_drive_file_id"
    t.index ["status"], name: "index_booking_documents_on_status"
    t.index ["uploaded_by_id"], name: "index_booking_documents_on_uploaded_by_id"
  end

  create_table "booking_runs", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.datetime "created_at", null: false
    t.datetime "ends_at", null: false
    t.text "notes"
    t.bigint "space_id", null: false
    t.datetime "starts_at", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_booking_runs_on_booking_id"
    t.index ["space_id", "starts_at", "ends_at"], name: "index_booking_runs_on_space_id_and_starts_at_and_ends_at"
    t.index ["space_id"], name: "index_booking_runs_on_space_id"
    t.index ["status"], name: "index_booking_runs_on_status"
    t.check_constraint "ends_at > starts_at", name: "booking_runs_valid_time_range"
    t.exclusion_constraint "space_id WITH =, tsrange(starts_at, ends_at, '[)'::text) WITH &&", where: "status <> 2", using: :gist, name: "booking_runs_no_space_overlap"
  end

  create_table "bookings", force: :cascade do |t|
    t.integer "booking_type", default: 0, null: false
    t.integer "contract_status", default: 0, null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.text "description"
    t.date "ends_on", null: false
    t.integer "estimated_attendance"
    t.text "internal_notes"
    t.bigint "patron_id", null: false
    t.bigint "primary_contact_id"
    t.boolean "public_event", default: false, null: false
    t.date "starts_on", null: false
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_type"], name: "index_bookings_on_booking_type"
    t.index ["created_by_id"], name: "index_bookings_on_created_by_id"
    t.index ["patron_id"], name: "index_bookings_on_patron_id"
    t.index ["primary_contact_id"], name: "index_bookings_on_primary_contact_id"
    t.index ["starts_on", "ends_on"], name: "index_bookings_on_starts_on_and_ends_on"
    t.index ["status"], name: "index_bookings_on_status"
    t.check_constraint "ends_on >= starts_on", name: "bookings_valid_date_range"
    t.check_constraint "estimated_attendance IS NULL OR estimated_attendance >= 0", name: "bookings_nonnegative_attendance"
  end

  create_table "contacts", force: :cascade do |t|
    t.boolean "billing_contact", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.text "notes"
    t.bigint "patron_id", null: false
    t.string "phone"
    t.boolean "primary_contact", default: false, null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["patron_id", "last_name", "first_name"], name: "index_contacts_on_patron_id_and_last_name_and_first_name"
    t.index ["patron_id"], name: "index_contacts_on_patron_id"
  end

  create_table "google_syncs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error_message"
    t.datetime "last_synced_at"
    t.jsonb "metadata", default: {}, null: false
    t.string "provider", default: "google", null: false
    t.string "resource_id"
    t.string "resource_type", null: false
    t.integer "status", default: 0, null: false
    t.bigint "syncable_id", null: false
    t.string "syncable_type", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "resource_type", "resource_id"], name: "index_google_syncs_on_provider_resource"
    t.index ["status"], name: "index_google_syncs_on_status"
    t.index ["syncable_type", "syncable_id", "provider", "resource_type"], name: "index_google_syncs_on_syncable_and_resource", unique: true
    t.index ["syncable_type", "syncable_id"], name: "index_google_syncs_on_syncable"
  end

  create_table "patrons", force: :cascade do |t|
    t.string "address_line1"
    t.string "address_line2"
    t.string "city"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name", null: false
    t.text "notes"
    t.integer "patron_type", default: 0, null: false
    t.string "phone"
    t.string "postal_code"
    t.string "state"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["name"], name: "index_patrons_on_name"
    t.index ["patron_type"], name: "index_patrons_on_patron_type"
    t.index ["status"], name: "index_patrons_on_status"
  end

  create_table "spaces", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_spaces_on_active"
    t.index ["name"], name: "index_spaces_on_name", unique: true
    t.check_constraint "capacity IS NULL OR capacity > 0", name: "spaces_positive_capacity"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.text "google_access_token_encrypted"
    t.datetime "google_calendar_connected_at"
    t.text "google_refresh_token_encrypted"
    t.datetime "google_token_expires_at"
    t.datetime "last_sign_in_at"
    t.string "login_nonce"
    t.string "name"
    t.string "provider", null: false
    t.integer "role", default: 0, null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["login_nonce"], name: "index_users_on_login_nonce", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "booking_documents", "bookings"
  add_foreign_key "booking_documents", "users", column: "uploaded_by_id"
  add_foreign_key "booking_runs", "bookings"
  add_foreign_key "booking_runs", "spaces"
  add_foreign_key "bookings", "contacts", column: "primary_contact_id"
  add_foreign_key "bookings", "patrons"
  add_foreign_key "bookings", "users", column: "created_by_id"
  add_foreign_key "contacts", "patrons"
end
