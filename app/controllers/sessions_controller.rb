class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def new
  end

  def create
    return connect_google_calendar if params[:provider] == "google_calendar"

    user = User.from_omniauth(request.env.fetch("omniauth.auth"))
    return_to = session.delete(:return_to).presence || root_path
    reset_session
    session[:user_id] = user.id
    redirect_to return_to, notice: "Signed in as #{user.email}."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to login_path, alert: "We could not sign you in: #{error.record.errors.full_messages.to_sentence}."
  end

  def failure
    redirect_to login_path, alert: "Google sign-in failed: #{params[:message].to_s.humanize}."
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Signed out."
  end

  private

  def connect_google_calendar
    unless current_user&.admin?
      redirect_to root_path, alert: "Administrator access is required."
      return
    end

    auth = request.env.fetch("omniauth.auth")
    unless auth.info.email.to_s.casecmp?(current_user.email)
      redirect_to settings_path, alert: "Connect the calendar using #{current_user.email}."
      return
    end

    current_user.connect_google_calendar!(auth.credentials)
    redirect_to settings_path, notice: "Google Calendar connected."
  end
end
