require "test_helper"

class Admin::SpacesControllerTest < ActionDispatch::IntegrationTest
  test "space management uses the account menu, theme picker, and custom confirmation dialog" do
    sign_in_as(users(:one))

    get admin_spaces_path

    assert_response :success
    assert_select "body[data-controller~='confirmation']"
    assert_select "summary[aria-label='Account menu']"
    assert_select "select[data-theme-select] option", 6
    assert_select "dialog[data-confirmation-target='dialog']"
    assert_select "button[data-confirm-message]", minimum: 1
    assert_select "[data-turbo-confirm]", count: 0
  end

  test "administrator can manage spaces" do
    sign_in_as(users(:one))

    assert_difference("Space.count") do
      post admin_spaces_path, params: {
        space: { name: "Scene Shop", capacity: 12, active: true, description: "Build and maintenance" }
      }
    end

    assert_redirected_to admin_spaces_path
  end

  test "staff cannot manage spaces" do
    sign_in_as(users(:two))

    get admin_spaces_path

    assert_redirected_to root_path
    assert_equal "Administrator access is required.", flash[:alert]
  end

  test "administrator can delete an unused space" do
    sign_in_as(users(:one))
    space = Space.create!(name: "Unused room")

    assert_difference("Space.count", -1) do
      delete admin_space_path(space)
    end

    assert_redirected_to admin_spaces_path
    assert_equal "Space deleted.", flash[:notice]

    follow_redirect!
    assert_select ".flash.notice[data-controller='dismissible'][data-dismissible-duration-value='10000']"
    assert_select "button.flash-dismiss[aria-label='Dismiss message']", text: "×"
    assert_select ".flash-progress[data-dismissible-target='progress']"
  end

  test "administrator cannot delete a space with booking runs" do
    sign_in_as(users(:one))
    space = spaces(:one)

    assert_no_difference("Space.count") do
      delete admin_space_path(space)
    end

    assert_redirected_to admin_spaces_path
    assert_equal "Cannot delete record because dependent booking runs exist", flash[:alert]
  end
end
