class Contact < ApplicationRecord
  belongs_to :patron

  has_many :primary_bookings, class_name: "Booking", foreign_key: :primary_contact_id, dependent: :nullify, inverse_of: :primary_contact

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, if: -> { phone.blank? }
  validates :phone, presence: true, if: -> { email.blank? }

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }

  def name
    [ first_name, last_name ].compact_blank.join(" ")
  end

  def label
    [ name, title.presence ].compact.join(", ")
  end
end
