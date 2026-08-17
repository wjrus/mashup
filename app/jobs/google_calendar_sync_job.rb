class GoogleCalendarSyncJob < ApplicationJob
  queue_as :default

  def perform(booking, connection)
    client = GoogleCalendarClient.new(user: connection)

    booking.booking_runs.find_each do |run|
      client.sync(run)
    rescue StandardError => error
      Rails.logger.error("Google Calendar sync failed for booking run #{run.id}: #{error.message}")
    end
  end
end
