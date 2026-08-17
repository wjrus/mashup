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

    overlap = BookingRun.where(space_id: space_id)
      .where.not(id: id)
      .where.not(status: :canceled)
      .where("starts_at < ? AND ends_at > ?", ends_at, starts_at)

    errors.add(:base, "space is already booked during this time") if overlap.exists?
  end
end
