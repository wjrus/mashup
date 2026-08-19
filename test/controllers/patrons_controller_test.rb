require "test_helper"

class PatronsControllerTest < ActionDispatch::IntegrationTest
  test "patron index exposes table action context" do
    sign_in_as(users(:two))

    get patrons_path

    assert_response :success
    assert_select "table caption.sr-only", text: "Patrons"
    assert_select "thead th[scope='col']", 5
    assert_select "tbody th[scope='row']", minimum: 1
    assert_select "a[aria-label^='Edit ']", minimum: 1
  end

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

  test "nested contact errors are associated with their fields" do
    sign_in_as(users(:two))

    post patrons_path, params: {
      patron: {
        name: "Touring Company",
        contacts_attributes: {
          "0" => { first_name: "Only", last_name: "", email: "", phone: "" }
        }
      }
    }

    assert_response :unprocessable_entity
    assert_select ".error-summary[tabindex='-1'][data-controller='error-summary']"
    assert_select "input[name='patron[contacts_attributes][0][last_name]'][aria-invalid='true'][aria-describedby]"
    assert_select ".field-error", text: "can't be blank", minimum: 1
  end
end
