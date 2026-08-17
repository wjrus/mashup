google_client_id = ENV["GOOGLE_CLIENT_ID"].presence
google_client_secret = ENV["GOOGLE_CLIENT_SECRET"].presence
staff_domains = ENV.fetch("STAFF_DOMAINS", "wjr.us,mashuprockandrollmusical.com").split(",").map(&:strip).reject(&:blank?)

if google_client_id && google_client_secret
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2,
      google_client_id,
      google_client_secret,
      hd: staff_domains,
      prompt: "select_account",
      access_type: "online",
      scope: "email,profile"

    provider :google_oauth2,
      google_client_id,
      google_client_secret,
      name: "google_calendar",
      hd: staff_domains,
      prompt: "consent select_account",
      access_type: "offline",
      scope: "email,profile,https://www.googleapis.com/auth/calendar.events"
  end
else
  Rails.logger.warn("[OmniAuth] Google OAuth provider not configured; login will be unavailable.")
end

OmniAuth.config.allowed_request_methods = %i[get post]
OmniAuth.config.silence_get_warning = true
