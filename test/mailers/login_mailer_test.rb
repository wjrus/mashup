require "test_helper"

class LoginMailerTest < ActionMailer::TestCase
  test "uses the MATCH product name" do
    email = LoginMailer.sign_in(users(:one))

    assert_equal "Your MATCH Bookings sign-in link", email.subject
    assert_includes email.html_part.body.to_s, "Sign in to MATCH Bookings"
    assert_includes email.text_part.body.to_s, "Sign in to MATCH Bookings"
    refute_match(/Mashup/i, email.body.to_s)
  end
end
