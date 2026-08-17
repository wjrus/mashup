class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    @upcoming_runs = BookingRun.includes(:space, booking: :patron).chronological.where("ends_at >= ?", Time.current).limit(12)
    @active_bookings = Booking.includes(:patron).where(status: [ :inquiry, :tentative, :confirmed ]).order(:starts_on).limit(10)
    @patron_count = Patron.count
    @booking_count = Booking.count
  end
end
