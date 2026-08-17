class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :patron, null: false, foreign_key: true
      t.references :primary_contact, null: true, foreign_key: { to_table: :contacts }
      t.string :title, null: false
      t.integer :booking_type, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.boolean :public_event, null: false, default: false
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.integer :estimated_attendance
      t.text :description
      t.text :internal_notes
      t.integer :contract_status, null: false, default: 0
      t.references :created_by, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :bookings, :booking_type
    add_index :bookings, :status
    add_index :bookings, [ :starts_on, :ends_on ]
  end
end
