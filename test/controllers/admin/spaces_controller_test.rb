require "test_helper"

class Admin::SpacesControllerTest < ActionDispatch::IntegrationTest
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
end
