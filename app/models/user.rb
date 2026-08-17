class User < ApplicationRecord
  enum :role, { staff: 0, admin: 1 }

  has_many :created_bookings, class_name: "Booking", foreign_key: :created_by_id, dependent: :nullify, inverse_of: :created_by
  has_many :uploaded_documents, class_name: "BookingDocument", foreign_key: :uploaded_by_id, dependent: :nullify, inverse_of: :uploaded_by

  validates :provider, :uid, :email, presence: true
  validates :email, uniqueness: true
  validates :uid, uniqueness: { scope: :provider }

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }

  def self.from_omniauth(auth)
    user = find_or_initialize_by(provider: auth.provider, uid: auth.uid)
    user.email = auth.info.email
    user.name = auth.info.name.presence || auth.info.email
    user.avatar_url = auth.info.image
    user.last_sign_in_at = Time.current
    user.save!
    user
  end
end
