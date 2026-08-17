class GoogleSync < ApplicationRecord
  belongs_to :syncable, polymorphic: true

  enum :status, {
    pending: 0,
    synced: 1,
    failed: 2,
    skipped: 3
  }

  validates :provider, :resource_type, presence: true
end
