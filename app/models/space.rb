class Space < ApplicationRecord
  has_many :booking_runs, dependent: :restrict_with_error
  has_many :bookings, through: :booking_runs

  validates :name, presence: true, uniqueness: true
  validates :capacity, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
end
