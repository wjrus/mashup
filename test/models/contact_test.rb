require "test_helper"

class ContactTest < ActiveSupport::TestCase
  test "requires either email or phone" do
    contact = contacts(:one)
    contact.email = nil
    contact.phone = nil

    assert_not contact.valid?
    assert_includes contact.errors[:email], "can't be blank"
    assert_includes contact.errors[:phone], "can't be blank"
  end
end
