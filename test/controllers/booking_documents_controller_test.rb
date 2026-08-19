require "test_helper"

class BookingDocumentsControllerTest < ActionDispatch::IntegrationTest
  test "invalid document fields render associated errors" do
    sign_in_as(users(:two))
    booking = bookings(:one)

    assert_no_difference("BookingDocument.count") do
      post booking_booking_documents_path(booking), params: {
        booking_document: { name: "", google_drive_url: "http://example.com/file" }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".error-summary[tabindex='-1'][data-controller='error-summary']"
    assert_select "#booking_document_name[aria-invalid='true'][aria-describedby='booking_document_name_error']"
    assert_select "#booking_document_name_error.field-error", text: "can't be blank"
    assert_select "#booking_document_google_drive_url[aria-invalid='true'][aria-describedby='booking_document_google_drive_url_error']"
  end
end
