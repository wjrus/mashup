class CreateGoogleSyncs < ActiveRecord::Migration[8.1]
  def change
    create_table :google_syncs do |t|
      t.references :syncable, polymorphic: true, null: false
      t.string :provider, null: false, default: "google"
      t.string :resource_type, null: false
      t.string :resource_id
      t.integer :status, null: false, default: 0
      t.datetime :last_synced_at
      t.text :error_message
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :google_syncs, [ :provider, :resource_type, :resource_id ], name: "index_google_syncs_on_provider_resource"
    add_index :google_syncs, :status
  end
end
