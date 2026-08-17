require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "builds or updates a user from google oauth data" do
    auth = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "new-user",
      info: {
        email: "New.User@WJR.US",
        name: "New User",
        image: "https://example.org/avatar.png"
      }
    )

    user = User.from_omniauth(auth)

    assert_equal "new.user@wjr.us", user.email
    assert_equal "New User", user.name
    assert_equal "https://example.org/avatar.png", user.avatar_url
    assert user.last_sign_in_at.present?
    assert user.staff?
  end

  test "assigns the configured administrator and only that administrator" do
    admin = users(:one)
    admin.valid?
    staff = users(:two)
    staff.valid?

    assert admin.admin?
    assert staff.staff?
  end

  test "rejects accounts outside the staff domains" do
    user = User.new(provider: "google_oauth2", uid: "outsider", email: "outsider@example.org")

    assert_not user.valid?
    assert_includes user.errors[:email], "is not authorized for staff access"
  end

  test "email login tokens are invalid after the nonce changes" do
    user = users(:two)
    token = user.generate_token_for(:email_login)

    assert_equal user, User.find_by_token_for(:email_login, token)
    user.regenerate_login_nonce
    assert_nil User.find_by_token_for(:email_login, token)
  end

  test "encrypts Google Calendar credentials at rest" do
    user = users(:one)

    user.google_access_token = "access-secret"
    user.google_refresh_token = "refresh-secret"

    assert_equal "access-secret", user.google_access_token
    assert_equal "refresh-secret", user.google_refresh_token
    assert_not_includes user.google_access_token_encrypted, "access-secret"
    assert_not_includes user.google_refresh_token_encrypted, "refresh-secret"
  end
end
