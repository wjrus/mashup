class BookingDocument < ApplicationRecord
  MAX_FILE_SIZE = 25.megabytes
  ALLOWED_CONTENT_TYPES = %w[
    application/pdf
    application/msword
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
    application/vnd.ms-excel
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    image/jpeg
    image/png
  ].freeze
  GOOGLE_DRIVE_HOSTS = %w[drive.google.com docs.google.com].freeze

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
  validate :google_drive_url_is_safe
  validate :file_is_acceptable

  private

  def google_drive_url_is_safe
    return if google_drive_url.blank?

    uri = URI.parse(google_drive_url)
    return if uri.is_a?(URI::HTTPS) && GOOGLE_DRIVE_HOSTS.include?(uri.host)

    errors.add(:google_drive_url, "must be a secure Google Drive URL")
  rescue URI::InvalidURIError
    errors.add(:google_drive_url, "must be a valid URL")
  end

  def file_is_acceptable
    return unless file.attached?

    errors.add(:file, "must be 25 MB or smaller") if file.blob.byte_size > MAX_FILE_SIZE
    errors.add(:file, "must be a PDF, Office document, JPEG, or PNG") unless ALLOWED_CONTENT_TYPES.include?(file.blob.content_type)
  end
end
