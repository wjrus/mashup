require "test_helper"

class PatronTest < ActiveSupport::TestCase
  test "uses MATCH as the public label for the internal mashup type" do
    patron = Patron.new(name: "Internal", patron_type: :mashup)

    assert_equal "MATCH", patron.display_type
    assert_includes Patron.patron_type_options, [ "MATCH", "mashup" ]
  end

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
