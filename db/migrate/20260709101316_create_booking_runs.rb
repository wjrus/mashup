class CreateBookingRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :booking_runs do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :space, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.integer :status, null: false, default: 0
      t.text :notes

      t.timestamps
    end

    add_index :booking_runs, [ :space_id, :starts_at, :ends_at ]
    add_index :booking_runs, :status
  end
end
