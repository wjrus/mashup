class Patron < ApplicationRecord
  enum :patron_type, {
    nonprofit: 0,
    for_profit: 1,
    partner: 2,
    mashup: 3
  }

  enum :status, {
    active: 0,
    inactive: 1,
    archived: 2
  }, prefix: true

  has_many :contacts, dependent: :destroy
  has_many :bookings, dependent: :restrict_with_error

  accepts_nested_attributes_for :contacts, reject_if: :blank_contact_attributes?, allow_destroy: true

  validates :name, presence: true

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }

  def display_type
    patron_type.humanize
  end

  private

  def blank_contact_attributes?(attributes)
    attributes.values_at("first_name", "last_name", "title", "email", "phone", "notes").all?(&:blank?)
  end
end
