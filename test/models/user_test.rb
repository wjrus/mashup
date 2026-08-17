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

  test "magic link tokens are invalid after the nonce changes" do
    user = users(:two)
    token = user.generate_token_for(:magic_link)

    assert_equal user, User.find_by_token_for(:magic_link, token)
    user.regenerate_magic_link_nonce
    assert_nil User.find_by_token_for(:magic_link, token)
  end
end
