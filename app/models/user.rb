class User < ApplicationRecord
  DEFAULT_ADMIN_EMAILS = %w[wjr@wjr.us].freeze
  DEFAULT_STAFF_DOMAINS = %w[wjr.us mashuprockandrollmusical.com].freeze

  enum :role, { staff: 0, admin: 1 }

  has_secure_token :magic_link_nonce

  generates_token_for :magic_link, expires_in: 15.minutes do
    magic_link_nonce
  end

  has_many :created_bookings, class_name: "Booking", foreign_key: :created_by_id, dependent: :nullify, inverse_of: :created_by
  has_many :uploaded_documents, class_name: "BookingDocument", foreign_key: :uploaded_by_id, dependent: :nullify, inverse_of: :uploaded_by

  validates :provider, :uid, :email, presence: true
  validates :email, uniqueness: true
  validates :uid, uniqueness: { scope: :provider }
  validate :email_is_authorized_for_staff_access

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }

  before_validation :apply_access_role

  def self.from_omniauth(auth)
    email = auth.info.email.to_s.strip.downcase
    user = find_by(email: email) || find_or_initialize_by(provider: auth.provider, uid: auth.uid)
    user.provider = auth.provider
    user.uid = auth.uid
    user.email = email
    user.name = auth.info.name.presence || auth.info.email
    user.avatar_url = auth.info.image
    user.last_sign_in_at = Time.current
    user.save!
    user
  end

  def self.for_magic_link(email)
    normalized_email = email.to_s.strip.downcase
    return unless authorized_email?(normalized_email)

    find_or_create_by!(email: normalized_email) do |user|
      user.provider = "magic_link"
      user.uid = normalized_email
      user.name = normalized_email
    end
  end

  def self.authorized_email?(email)
    normalized_email = email.to_s.strip.downcase
    return false unless normalized_email.match?(URI::MailTo::EMAIL_REGEXP)

    admin_emails.include?(normalized_email) || staff_domains.include?(normalized_email.split("@").last)
  end

  def self.admin_emails
    ENV.fetch("ADMIN_EMAILS", DEFAULT_ADMIN_EMAILS.join(",")).split(",").map { |email| email.strip.downcase }.reject(&:blank?)
  end

  def self.staff_domains
    ENV.fetch("STAFF_DOMAINS", DEFAULT_STAFF_DOMAINS.join(",")).split(",").map { |domain| domain.strip.downcase }.reject(&:blank?)
  end

  private

  def email_is_authorized_for_staff_access
    errors.add(:email, "is not authorized for staff access") unless self.class.authorized_email?(email)
  end

  def apply_access_role
    self.role = self.class.admin_emails.include?(email.to_s.downcase) ? :admin : :staff
  end
end
