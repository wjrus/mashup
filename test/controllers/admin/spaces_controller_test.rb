require "test_helper"

class Admin::SpacesControllerTest < ActionDispatch::IntegrationTest
  test "space management uses the account menu, theme picker, and custom confirmation dialog" do
    sign_in_as(users(:one))

    get admin_spaces_path

    assert_response :success
    assert_select "body[data-controller~='confirmation']"
    assert_select "a.skip-link[href='#main-content']", text: "Skip to main content"
    assert_select "main#main-content[tabindex='-1']"
    assert_select "nav[aria-label='Primary navigation'] a[aria-current='page']", text: "Settings"
    assert_select "summary[aria-label='Account menu']"
    assert_select "select[data-theme-select] option", 6
    assert_select "dialog[data-confirmation-target='dialog']"
    assert_select "button[data-confirm-message]", minimum: 1
    assert_select "[data-turbo-confirm]", count: 0
    assert_select "th[scope='col']", 4
    assert_select "th[scope='row']", minimum: 1
    assert_select ".table-actions" do
      assert_select "a.compact-button[aria-label^='Edit ']"
      assert_select "form.table-action-form button.compact-button[aria-label^='Delete ']"
    end
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

  test "invalid space fields are identified and described" do
    sign_in_as(users(:one))

    post admin_spaces_path, params: { space: { name: "", capacity: 0 } }

    assert_response :unprocessable_entity
    assert_select ".error-summary[role='alert'][tabindex='-1'][data-controller='error-summary']"
    assert_select "#space_name[aria-invalid='true'][aria-describedby='space_name_error']"
    assert_select "#space_name_error.field-error", text: "can't be blank"
    assert_select "#space_capacity[aria-invalid='true'][aria-describedby='space_capacity_error']"
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

    follow_redirect!
    assert_select "main#main-content .flash.alert[role='alert'][aria-atomic='true']"
    assert_select ".flash.alert[data-dismissible-duration-value]", count: 0
    assert_select ".flash.alert .flash-progress", count: 0
  end
end
