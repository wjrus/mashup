require "test_helper"

class PasswordlessSessionsControllerTest < ActionDispatch::IntegrationTest
  test "sign-in screen offers the browser theme picker" do
    get login_path

    assert_response :success
    assert_select "link[rel='icon'][href='/icon.svg'][type='image/svg+xml'][sizes='any']"
    assert_select "link[rel='icon'][href='/icon.png'][type='image/png'][sizes='512x512']"
    assert_select ".sign-in-theme select[data-theme-select] option", 6
  end

  test "emails an authorized staff member without revealing account status" do
    assert_emails 1 do
      post email_login_path, params: { email: users(:two).email }
    end

    assert_redirected_to login_path
    assert_equal "If that email is authorized, a sign-in link has been sent.", flash[:notice]

    follow_redirect!
    assert_select "main#main-content .flash.notice[data-dismissible-duration-value='10000']"
    assert_select ".flash.notice .flash-progress[data-dismissible-target='progress']"
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

    follow_redirect!
    assert_select "main#main-content .flash.alert[role='alert']"
    assert_select ".flash.alert[data-dismissible-duration-value]", count: 0
    assert_select ".flash.alert .flash-progress", count: 0
  end
end
