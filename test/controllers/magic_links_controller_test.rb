require "test_helper"

class MagicLinksControllerTest < ActionDispatch::IntegrationTest
  test "emails an authorized staff member without revealing account status" do
    assert_emails 1 do
      post request_magic_link_path, params: { email: users(:two).email }
    end

    assert_redirected_to sign_in_path
    assert_equal "If that email is authorized, a sign-in link has been sent.", flash[:notice]
  end

  test "does not create or email an unauthorized account" do
    assert_no_difference("User.count") do
      assert_no_emails do
        post request_magic_link_path, params: { email: "somebody@example.org" }
      end
    end

    assert_redirected_to sign_in_path
  end

  test "signs in once with a valid token" do
    user = users(:two)
    token = user.generate_token_for(:magic_link)

    get magic_link_path(token: token)
    assert_redirected_to root_path

    get magic_link_path(token: token)
    assert_redirected_to sign_in_path
    assert_equal "That sign-in link is invalid or has expired.", flash[:alert]
  end
end
