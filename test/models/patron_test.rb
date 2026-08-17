require "test_helper"

class PatronTest < ActiveSupport::TestCase
  test "ignores a blank nested contact even when checkbox values are submitted" do
    patron = Patron.new(
      name: "New Patron",
      contacts_attributes: {
        "0" => { first_name: "", last_name: "", email: "", phone: "", primary_contact: "0", billing_contact: "0" }
      }
    )

    assert patron.valid?
    assert_empty patron.contacts
  end
end
