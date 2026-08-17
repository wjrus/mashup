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

  test "ignores a blank nested run when its default status is submitted" do
    booking = Booking.new(
      patron: patrons(:one),
      title: "Booking without runs",
      starts_on: Date.new(2026, 8, 1),
      ends_on: Date.new(2026, 8, 1),
      booking_runs_attributes: {
        "0" => { space_id: "", starts_at: "", ends_at: "", status: "planned" }
      }
    )

    assert booking.valid?
    assert_empty booking.booking_runs
  end

  test "requires the primary contact to belong to the patron" do
    booking = bookings(:one)
    booking.primary_contact = contacts(:two)

    assert_not booking.valid?
    assert_includes booking.errors[:primary_contact], "must belong to the selected patron"
  end

  test "canceling a booking releases its scheduled runs" do
    booking = bookings(:one)

    booking.update!(status: :canceled)

    assert booking.booking_runs.reload.all?(&:canceled?)
  end
end
