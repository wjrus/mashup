require "test_helper"

class BookingRunTest < ActiveSupport::TestCase
  test "requires the run to end after it starts" do
    run = booking_runs(:one)
    run.ends_at = run.starts_at

    assert_not run.valid?
    assert_includes run.errors[:ends_at], "must be after the start time"
  end

  test "rejects overlapping runs in the same space" do
    existing = booking_runs(:one)
    run = BookingRun.new(
      booking: bookings(:two),
      space: existing.space,
      starts_at: existing.starts_at + 30.minutes,
      ends_at: existing.ends_at + 30.minutes
    )

    assert_not run.valid?
    assert_includes run.errors[:base], "space is already booked during this time"
  end

  test "allows overlapping runs in different spaces" do
    existing = booking_runs(:one)
    alternate_space = Space.create!(name: "Studio", capacity: 20)
    run = BookingRun.new(
      booking: bookings(:two),
      space: alternate_space,
      starts_at: existing.starts_at + 30.minutes,
      ends_at: existing.ends_at + 30.minutes
    )

    assert run.valid?
  end
end
