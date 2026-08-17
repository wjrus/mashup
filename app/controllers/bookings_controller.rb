class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: %i[show edit update sync_calendar]

  def index
    @bookings = Booking.includes(:patron, :primary_contact).recent_first
    @bookings = @bookings.where(status: params[:status]) if params[:status].present? && Booking.statuses.key?(params[:status])
  end

  def show
    @booking_document = @booking.booking_documents.build
  end

  def new
    @booking = Booking.new(starts_on: Date.current, ends_on: Date.current, contract_status: :needed)
    @booking.assign_attributes(params.fetch(:booking, {}).permit(:patron_id))
    @booking.booking_runs.build
  end

  def edit
    @booking.booking_runs.build if @booking.booking_runs.empty?
  end

  def create
    @booking = Booking.new(booking_params)
    @booking.created_by = current_user
    if @booking.save
      redirect_to @booking, notice: "Booking created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @booking.update(booking_params)
      redirect_to @booking, notice: "Booking updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def sync_calendar
    connection = User.admin.find(&:google_calendar_connected?)

    if connection
      GoogleCalendarSyncJob.perform_later(@booking, connection)
      redirect_to @booking, notice: "Calendar sync queued."
    else
      redirect_to @booking, alert: "Google Calendar is not connected. Ask an administrator to connect it in Settings."
    end
  end

  private

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(
      :patron_id, :primary_contact_id, :title, :booking_type, :status, :public_event,
      :starts_on, :ends_on, :estimated_attendance, :description, :internal_notes, :contract_status,
      booking_runs_attributes: [ :id, :space_id, :starts_at, :ends_at, :status, :notes, :_destroy ]
    )
  end
end
