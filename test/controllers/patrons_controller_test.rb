require "test_helper"

class PatronsControllerTest < ActionDispatch::IntegrationTest
  test "creates a patron while ignoring an untouched contact row" do
    sign_in_as(users(:two))

    assert_difference("Patron.count") do
      assert_no_difference("Contact.count") do
        post patrons_path, params: {
          patron: {
            name: "Touring Company",
            patron_type: "nonprofit",
            status: "active",
            contacts_attributes: {
              "0" => { first_name: "", last_name: "", email: "", phone: "", primary_contact: "0", billing_contact: "0" }
            }
          }
        }
      end
    end

    assert_response :redirect
  end
end
