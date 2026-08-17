class BookingDocument < ApplicationRecord
  belongs_to :booking
  belongs_to :uploaded_by, class_name: "User", optional: true

  has_one_attached :file

  enum :document_type, {
    contract: 0,
    rider: 1,
    invoice: 2,
    insurance: 3,
    other: 4
  }

  enum :status, {
    draft: 0,
    pending_signature: 1,
    complete: 2,
    superseded: 3
  }

  validates :name, presence: true
end
