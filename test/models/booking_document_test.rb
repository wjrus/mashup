require "test_helper"

class BookingDocumentTest < ActiveSupport::TestCase
  test "accepts only secure Google Drive URLs" do
    document = booking_documents(:one)
    document.google_drive_url = "javascript:alert(1)"

    assert_not document.valid?
    assert_includes document.errors[:google_drive_url], "must be a secure Google Drive URL"

    document.google_drive_url = "https://drive.google.com/file/d/example/view"
    assert document.valid?
  end

  test "rejects unsupported uploaded file types" do
    document = booking_documents(:one)
    document.google_drive_url = nil
    document.file.attach(io: StringIO.new("executable"), filename: "contract.exe", content_type: "application/x-msdownload")

    assert_not document.valid?
    assert_includes document.errors[:file], "must be a PDF, Office document, JPEG, or PNG"
  end
end
