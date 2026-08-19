require "test_helper"

class PasswordlessSessionsControllerTest < ActionDispatch::IntegrationTest
  test "sign-in screen offers the browser theme picker" do
    get login_path

    assert_response :success
    assert_select ".sign-in-theme select[data-theme-select] option", 6
  end

  test "emails an authorized staff member without revealing account status" do
    assert_emails 1 do
      post email_login_path, params: { email: users(:two).email }
    end

    assert_redirected_to login_path
    assert_equal "If that email is authorized, a sign-in link has been sent.", flash[:notice]
  end

  test "does not create or email an unauthorized account" do
    assert_no_difference("User.count") do
      assert_no_emails do
        post email_login_path, params: { email: "somebody@example.org" }
      end
    end

    assert_redirected_to login_path
  end

  test "signs in once with a valid token" do
    user = users(:two)
    token = user.generate_token_for(:email_login)

    get verify_login_path(token: token)
    assert_redirected_to root_path

    get verify_login_path(token: token)
    assert_redirected_to login_path
    assert_equal "That sign-in link is invalid or has expired.", flash[:alert]
  end
end
