class BookingDocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking
  before_action :set_document, only: %i[show open]

  def show
    return head :not_found unless @document.file.attached?

    send_data @document.file.download,
      filename: @document.file.filename.to_s,
      type: @document.file.content_type,
      disposition: "attachment"
  end

  def open
    uri = URI.parse(@document.google_drive_url.to_s)
    base_url = case uri.host
    when "drive.google.com" then "https://drive.google.com"
    when "docs.google.com" then "https://docs.google.com"
    end

    return head :not_found unless uri.is_a?(URI::HTTPS) && base_url

    redirect_to "#{base_url}#{uri.request_uri}", allow_other_host: true
  rescue URI::InvalidURIError
    head :not_found
  end

  def create
    @document = @booking.booking_documents.build(document_params)
    @document.uploaded_by = current_user

    if @document.save
      redirect_to @booking, notice: "Document added."
    else
      redirect_to @booking, alert: @document.errors.full_messages.to_sentence
    end
  end

  private

  def set_booking
    @booking = Booking.find(params[:booking_id])
  end

  def set_document
    @document = @booking.booking_documents.find(params[:id])
  end

  def document_params
    params.require(:booking_document).permit(:name, :document_type, :status, :google_drive_file_id, :google_drive_url, :due_on, :signed_on, :notes, :file)
  end
end
