class RenameMagicLinkNonceToLoginNonce < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :magic_link_nonce, :login_nonce
  end
end
