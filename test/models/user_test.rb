require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "builds or updates a user from google oauth data" do
    auth = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "new-user",
      info: {
        email: "New.User@Example.Org",
        name: "New User",
        image: "https://example.org/avatar.png"
      }
    )

    user = User.from_omniauth(auth)

    assert_equal "new.user@example.org", user.email
    assert_equal "New User", user.name
    assert_equal "https://example.org/avatar.png", user.avatar_url
    assert user.last_sign_in_at.present?
  end
end
