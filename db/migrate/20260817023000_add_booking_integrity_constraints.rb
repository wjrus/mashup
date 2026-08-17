class AddBookingIntegrityConstraints < ActiveRecord::Migration[8.1]
  def change
    enable_extension "btree_gist"

    add_check_constraint :bookings, "ends_on >= starts_on", name: "bookings_valid_date_range"
    add_check_constraint :bookings, "estimated_attendance IS NULL OR estimated_attendance >= 0", name: "bookings_nonnegative_attendance"
    add_check_constraint :booking_runs, "ends_at > starts_at", name: "booking_runs_valid_time_range"
    add_check_constraint :spaces, "capacity IS NULL OR capacity > 0", name: "spaces_positive_capacity"

    add_exclusion_constraint :booking_runs,
      "space_id WITH =, tsrange(starts_at, ends_at, '[)') WITH &&",
      where: "(status <> 2)",
      using: :gist,
      name: "booking_runs_no_space_overlap"
  end
end
