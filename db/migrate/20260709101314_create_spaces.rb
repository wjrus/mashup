class CreateSpaces < ActiveRecord::Migration[8.1]
  def change
    create_table :spaces do |t|
      t.string :name, null: false
      t.integer :capacity
      t.boolean :active, null: false, default: true
      t.text :description

      t.timestamps
    end

    add_index :spaces, :name, unique: true
    add_index :spaces, :active
  end
end
