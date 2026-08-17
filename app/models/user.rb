class User < ApplicationRecord
  DEFAULT_ADMIN_EMAILS = %w[wjr@wjr.us].freeze
  DEFAULT_STAFF_DOMAINS = %w[wjr.us mashuprockandrollmusical.com].freeze

  enum :role, { staff: 0, admin: 1 }

  has_secure_token :login_nonce

  generates_token_for :email_login, expires_in: 15.minutes do
    login_nonce
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

  def self.for_email_login(email)
    normalized_email = email.to_s.strip.downcase
    return unless authorized_email?(normalized_email)

    find_or_create_by!(email: normalized_email) do |user|
      user.provider = "email"
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

  def connect_google_calendar!(credentials)
    self.google_access_token = credentials.token
    self.google_refresh_token = credentials.refresh_token if credentials.refresh_token.present?
    self.google_token_expires_at = Time.zone.at(credentials.expires_at) if credentials.expires_at.present?
    self.google_calendar_connected_at = Time.current
    save!
  end

  def google_calendar_connected?
    google_refresh_token.present? || google_access_token.present?
  end

  def google_access_token
    decrypt_google_credential(google_access_token_encrypted)
  end

  def google_access_token=(value)
    self.google_access_token_encrypted = encrypt_google_credential(value)
  end

  def google_refresh_token
    decrypt_google_credential(google_refresh_token_encrypted)
  end

  def google_refresh_token=(value)
    self.google_refresh_token_encrypted = encrypt_google_credential(value)
  end

  private

  def email_is_authorized_for_staff_access
    errors.add(:email, "is not authorized for staff access") unless self.class.authorized_email?(email)
  end

  def apply_access_role
    self.role = self.class.admin_emails.include?(email.to_s.downcase) ? :admin : :staff
  end

  def encrypt_google_credential(value)
    return if value.blank?

    self.class.send(:google_credential_encryptor).encrypt_and_sign(value)
  end

  def decrypt_google_credential(value)
    return if value.blank?

    self.class.send(:google_credential_encryptor).decrypt_and_verify(value)
  end

  def self.google_credential_encryptor
    @google_credential_encryptor ||= begin
      key = Rails.application.key_generator.generate_key("google-calendar-oauth", ActiveSupport::MessageEncryptor.key_len)
      ActiveSupport::MessageEncryptor.new(key)
    end
  end

  private_class_method :google_credential_encryptor
end
