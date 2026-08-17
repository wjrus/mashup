class AddGoogleCalendarCredentialsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :google_access_token_encrypted, :text
    add_column :users, :google_refresh_token_encrypted, :text
    add_column :users, :google_token_expires_at, :datetime
    add_column :users, :google_calendar_connected_at, :datetime

    add_index :google_syncs,
      %i[syncable_type syncable_id provider resource_type],
      unique: true,
      name: "index_google_syncs_on_syncable_and_resource"
  end
end
