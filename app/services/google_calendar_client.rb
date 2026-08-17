class GoogleCalendarClient
  CALENDAR_RESOURCE_TYPE = "calendar_event"

  def initialize(user:, service: nil, calendar_id: ENV.fetch("GOOGLE_CALENDAR_ID", "primary"))
    @user = user
    @service = service || build_service
    @calendar_id = calendar_id
  end

  def sync(run)
    sync_record = run.google_syncs.find_or_initialize_by(provider: "google", resource_type: CALENDAR_RESOURCE_TYPE)
    sync_record.update!(status: :pending, error_message: nil)

    if run.canceled? || run.booking.canceled?
      delete_event(sync_record)
    else
      upsert_event(run, sync_record)
    end
  rescue StandardError => error
    sync_record&.update(status: :failed, error_message: error.message)
    raise
  end

  private

  def upsert_event(run, sync_record)
    event = calendar_event(run)

    result = if sync_record.resource_id.present?
      update_event(sync_record.resource_id, event)
    else
      @service.insert_event(@calendar_id, event, send_updates: "none")
    end

    sync_record.update!(
      status: :synced,
      resource_id: result.id,
      last_synced_at: Time.current,
      metadata: { html_link: result.html_link }.compact
    )
  end

  def update_event(resource_id, event)
    @service.update_event(@calendar_id, resource_id, event, send_updates: "none")
  rescue Google::Apis::ClientError => error
    raise unless error.status_code == 404

    @service.insert_event(@calendar_id, event, send_updates: "none")
  end

  def delete_event(sync_record)
    @service.delete_event(@calendar_id, sync_record.resource_id, send_updates: "none") if sync_record.resource_id.present?
    sync_record.update!(status: :skipped, resource_id: nil, last_synced_at: Time.current, metadata: {})
  rescue Google::Apis::ClientError => error
    raise unless error.status_code == 404

    sync_record.update!(status: :skipped, resource_id: nil, last_synced_at: Time.current, metadata: {})
  end

  def calendar_event(run)
    booking = run.booking

    Google::Apis::CalendarV3::Event.new(
      summary: booking.title,
      description: [ booking.patron.name, booking.display_type, booking.description ].compact_blank.join("\n"),
      location: run.space.name,
      start: event_time(run.starts_at),
      end: event_time(run.ends_at),
      extended_properties: Google::Apis::CalendarV3::Event::ExtendedProperties.new(
        private: { booking_id: booking.id.to_s, booking_run_id: run.id.to_s }
      )
    )
  end

  def event_time(time)
    Google::Apis::CalendarV3::EventDateTime.new(
      date_time: time.iso8601,
      time_zone: Time.zone.tzinfo.name
    )
  end

  def build_service
    authorization = Signet::OAuth2::Client.new(
      client_id: ENV.fetch("GOOGLE_CLIENT_ID"),
      client_secret: ENV.fetch("GOOGLE_CLIENT_SECRET"),
      token_credential_uri: "https://oauth2.googleapis.com/token",
      access_token: @user.google_access_token,
      refresh_token: @user.google_refresh_token,
      expires_at: @user.google_token_expires_at
    )

    refresh_authorization(authorization) if authorization.expired?

    Google::Apis::CalendarV3::CalendarService.new.tap do |service|
      service.authorization = authorization
    end
  end

  def refresh_authorization(authorization)
    authorization.fetch_access_token!
    @user.google_access_token = authorization.access_token
    @user.google_token_expires_at = Time.zone.at(authorization.expires_at)
    @user.save!
  end
end
