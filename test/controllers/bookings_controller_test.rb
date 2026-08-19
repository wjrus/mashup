require "test_helper"

class BookingsControllerTest < ActionDispatch::IntegrationTest
  test "booking form confirms cancellation and run removal with the custom dialog" do
    sign_in_as(users(:two))

    get edit_booking_path(bookings(:one))

    assert_response :success
    assert_select "form[data-confirm-when-field='booking[status]'][data-confirm-when-value='canceled']"
    assert_select "button[data-action='nested-form#remove'][data-confirm-message]", minimum: 1
    assert_select "[data-controller='nested-form'][data-nested-form-item-name-value='Run']" do
      assert_select "button[data-nested-form-target='addButton']"
      assert_select "[role='status'][data-nested-form-target='status']"
    end
    assert_select "[data-turbo-confirm]", count: 0
  end

  test "booking index exposes table and current filter semantics" do
    sign_in_as(users(:two))

    get bookings_path(status: "tentative")

    assert_response :success
    assert_select "a[aria-current='page']", text: "Tentative"
    assert_select "table caption.sr-only", text: "Bookings"
    assert_select "thead th[scope='col']", 6
    assert_select "tbody th[scope='row']", minimum: 1
    assert_select "a[aria-label^='Edit ']", minimum: 1
  end

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
    assert_select ".error-summary[tabindex='-1'][data-controller='error-summary']"
    assert_select "#booking_primary_contact_id[aria-invalid='true'][aria-describedby='booking_primary_contact_error']"
    assert_select "#booking_primary_contact_error.field-error", text: "must belong to the selected patron"
  end
end
