class BookingDocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking

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

  def document_params
    params.require(:booking_document).permit(:name, :document_type, :status, :google_drive_file_id, :google_drive_url, :due_on, :signed_on, :notes, :file)
  end
end
