require "test_helper"

class BookingTest < ActiveSupport::TestCase
  test "requires an end date on or after the start date" do
    booking = bookings(:one)
    booking.starts_on = Date.new(2026, 7, 10)
    booking.ends_on = Date.new(2026, 7, 9)

    assert_not booking.valid?
    assert_includes booking.errors[:ends_on], "must be on or after the start date"
  end

  test "formats a multi day date span" do
    booking = bookings(:one)
    booking.starts_on = Date.new(2026, 7, 9)
    booking.ends_on = Date.new(2026, 7, 12)

    assert_includes booking.date_span, "July"
    assert_includes booking.date_span, "-"
  end
end
