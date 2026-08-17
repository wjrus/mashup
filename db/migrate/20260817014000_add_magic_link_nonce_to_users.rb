class AddMagicLinkNonceToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :magic_link_nonce, :string
    add_index :users, :magic_link_nonce, unique: true
  end
end
