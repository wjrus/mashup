require "test_helper"

class BookingsControllerTest < ActionDispatch::IntegrationTest
  test "creates a booking while ignoring an untouched run row" do
    sign_in_as(users(:two))

    assert_difference("Booking.count") do
      assert_no_difference("BookingRun.count") do
        post bookings_path, params: {
          booking: {
            patron_id: patrons(:one).id,
            title: "New inquiry",
            booking_type: "rehearsal",
            status: "inquiry",
            contract_status: "needed",
            starts_on: "2026-09-01",
            ends_on: "2026-09-01",
            booking_runs_attributes: {
              "0" => { space_id: "", starts_at: "", ends_at: "", status: "planned" }
            }
          }
        }
      end
    end

    assert_response :redirect
  end

  test "rejects a contact from another patron" do
    sign_in_as(users(:two))

    assert_no_difference("Booking.count") do
      post bookings_path, params: {
        booking: {
          patron_id: patrons(:one).id,
          primary_contact_id: contacts(:two).id,
          title: "Mismatched contact",
          starts_on: "2026-09-01",
          ends_on: "2026-09-01"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes response.body, "Primary contact must belong to the selected patron"
  end
end
