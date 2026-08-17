class BookingRun < ApplicationRecord
  belongs_to :booking
  belongs_to :space

  has_many :google_syncs, as: :syncable, dependent: :destroy

  enum :status, {
    planned: 0,
    held: 1,
    canceled: 2
  }

  validates :starts_at, :ends_at, presence: true
  validate :ends_at_is_after_starts_at
  validate :occurs_within_booking_dates
  validate :space_is_available

  scope :chronological, -> { order(:starts_at, :ends_at) }

  def time_span
    "#{starts_at.to_fs(:long)} - #{ends_at.to_fs(:time)}"
  end

  private

  def ends_at_is_after_starts_at
    return if starts_at.blank? || ends_at.blank? || ends_at > starts_at

    errors.add(:ends_at, "must be after the start time")
  end

  def space_is_available
    return if space_id.blank? || starts_at.blank? || ends_at.blank? || canceled?

    overlap = BookingRun.joins(:booking).where(space_id: space_id)
      .where.not(id: id)
      .where.not(status: :canceled)
      .where.not(bookings: { status: Booking.statuses[:canceled] })
      .where("starts_at < ? AND ends_at > ?", ends_at, starts_at)

    errors.add(:base, "space is already booked during this time") if overlap.exists?
  end

  def occurs_within_booking_dates
    return if booking.blank? || starts_at.blank? || ends_at.blank? || booking.starts_on.blank? || booking.ends_on.blank?
    return if starts_at.to_date >= booking.starts_on && ends_at.to_date <= booking.ends_on

    errors.add(:base, "run must occur within the booking dates")
  end
end
