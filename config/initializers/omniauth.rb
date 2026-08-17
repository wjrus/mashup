google_client_id = ENV["GOOGLE_CLIENT_ID"].presence
google_client_secret = ENV["GOOGLE_CLIENT_SECRET"].presence

if google_client_id && google_client_secret
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2,
      google_client_id,
      google_client_secret,
      hd: ENV["AUTH_DOMAIN"].presence,
      prompt: "select_account",
      access_type: "online",
      scope: "email,profile"
  end
else
  Rails.logger.warn("[OmniAuth] Google OAuth provider not configured; login will be unavailable.")
end

OmniAuth.config.allowed_request_methods = %i[get post]
OmniAuth.config.silence_get_warning = true
