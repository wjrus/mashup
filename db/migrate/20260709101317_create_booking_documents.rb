class CreateBookingDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :booking_documents do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :uploaded_by, null: true, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.integer :document_type, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.string :google_drive_file_id
      t.string :google_drive_url
      t.date :due_on
      t.date :signed_on
      t.text :notes

      t.timestamps
    end

    add_index :booking_documents, :document_type
    add_index :booking_documents, :status
    add_index :booking_documents, :google_drive_file_id
  end
end
