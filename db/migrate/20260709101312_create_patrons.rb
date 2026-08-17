class CreatePatrons < ActiveRecord::Migration[8.1]
  def change
    create_table :patrons do |t|
      t.string :name, null: false
      t.integer :patron_type, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.string :email
      t.string :phone
      t.string :website
      t.string :address_line1
      t.string :address_line2
      t.string :city
      t.string :state
      t.string :postal_code
      t.text :notes

      t.timestamps
    end

    add_index :patrons, :name
    add_index :patrons, :patron_type
    add_index :patrons, :status
  end
end
