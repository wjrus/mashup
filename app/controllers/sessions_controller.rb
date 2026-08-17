class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def new
  end

  def create
    user = User.from_omniauth(request.env.fetch("omniauth.auth"))
    session[:user_id] = user.id
    redirect_to session.delete(:return_to).presence || root_path, notice: "Signed in as #{user.email}."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to sign_in_path, alert: "We could not sign you in: #{error.record.errors.full_messages.to_sentence}."
  end

  def failure
    redirect_to sign_in_path, alert: "Google sign-in failed: #{params[:message].to_s.humanize}."
  end

  def destroy
    reset_session
    redirect_to sign_in_path, notice: "Signed out."
  end
end
