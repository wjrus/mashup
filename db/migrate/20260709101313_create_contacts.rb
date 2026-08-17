class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts do |t|
      t.references :patron, null: false, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :title
      t.string :email
      t.string :phone
      t.boolean :primary_contact, null: false, default: false
      t.boolean :billing_contact, null: false, default: false
      t.text :notes

      t.timestamps
    end

    add_index :contacts, [ :patron_id, :last_name, :first_name ]
  end
end
