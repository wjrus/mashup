require "test_helper"

class GoogleCalendarClientTest < ActiveSupport::TestCase
  FakeEvent = Data.define(:id, :html_link)

  class FakeCalendarService
    attr_reader :deleted_ids, :inserted_events, :updated_events

    def initialize
      @deleted_ids = []
      @inserted_events = []
      @updated_events = []
    end

    def insert_event(_calendar_id, event, send_updates:)
      @inserted_events << [ event, send_updates ]
      FakeEvent.new(id: "google-event-1", html_link: "https://calendar.google.com/event/1")
    end

    def update_event(_calendar_id, event_id, event, send_updates:)
      @updated_events << [ event_id, event, send_updates ]
      FakeEvent.new(id: event_id, html_link: "https://calendar.google.com/event/1")
    end

    def delete_event(_calendar_id, event_id, send_updates:)
      @deleted_ids << [ event_id, send_updates ]
    end
  end

  test "creates a calendar event for a booking run" do
    service = FakeCalendarService.new
    run = booking_runs(:one)

    GoogleCalendarClient.new(user: users(:one), service: service, calendar_id: "test-calendar").sync(run)

    sync = run.google_syncs.find_by!(provider: "google", resource_type: "calendar_event")
    event = service.inserted_events.first.first
    assert_equal "google-event-1", sync.resource_id
    assert sync.synced?
    assert_equal run.booking.title, event.summary
    assert_equal run.space.name, event.location
    assert_equal run.id.to_s, event.extended_properties.private[:booking_run_id]
  end

  test "updates an existing calendar event" do
    service = FakeCalendarService.new
    run = booking_runs(:one)
    run.google_syncs.create!(provider: "google", resource_type: "calendar_event", resource_id: "existing-event")

    GoogleCalendarClient.new(user: users(:one), service: service).sync(run)

    assert_equal "existing-event", service.updated_events.first.first
    assert_empty service.inserted_events
  end

  test "deletes the event when a run is canceled" do
    service = FakeCalendarService.new
    run = booking_runs(:one)
    run.update!(status: :canceled)
    sync = run.google_syncs.create!(provider: "google", resource_type: "calendar_event", resource_id: "existing-event")

    GoogleCalendarClient.new(user: users(:one), service: service).sync(run)

    assert_equal [ "existing-event", "none" ], service.deleted_ids.first
    assert sync.reload.skipped?
    assert_nil sync.resource_id
  end
end
