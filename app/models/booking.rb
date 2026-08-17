class Booking < ApplicationRecord
  BOOKING_TYPES = {
    performance_public: 0,
    rehearsal: 1,
    party: 2,
    special_event: 3,
    maintenance: 4,
    class_workshop_public: 5,
    other: 6
  }.freeze

  belongs_to :patron
  belongs_to :primary_contact, class_name: "Contact", optional: true
  belongs_to :created_by, class_name: "User", optional: true

  has_many :booking_runs, dependent: :destroy
  has_many :spaces, through: :booking_runs
  has_many :booking_documents, dependent: :destroy
  has_many :google_syncs, as: :syncable, dependent: :destroy

  accepts_nested_attributes_for :booking_runs, reject_if: :all_blank, allow_destroy: true

  enum :booking_type, BOOKING_TYPES
  enum :status, {
    inquiry: 0,
    tentative: 1,
    confirmed: 2,
    completed: 3,
    canceled: 4
  }
  enum :contract_status, {
    not_required: 0,
    needed: 1,
    sent: 2,
    signed: 3,
    filed: 4
  }, prefix: :contract

  validates :title, :starts_on, :ends_on, presence: true
  validates :estimated_attendance, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validate :ends_on_is_not_before_starts_on

  scope :upcoming, -> { where("ends_on >= ?", Date.current).order(:starts_on, :title) }
  scope :recent_first, -> { order(starts_on: :desc, created_at: :desc) }

  def display_type
    booking_type.humanize
  end

  def date_span
    return starts_on.to_fs(:long) if starts_on == ends_on

    "#{starts_on.to_fs(:long)} - #{ends_on.to_fs(:long)}"
  end

  private

  def ends_on_is_not_before_starts_on
    return if starts_on.blank? || ends_on.blank? || ends_on >= starts_on

    errors.add(:ends_on, "must be on or after the start date")
  end
end
