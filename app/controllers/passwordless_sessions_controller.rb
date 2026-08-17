class PasswordlessSessionsController < ApplicationController
  rate_limit to: 5, within: 15.minutes, only: :create

  def create
    user = User.for_email_login(params[:email])
    LoginMailer.sign_in(user).deliver_now if user

    redirect_to login_path, notice: "If that email is authorized, a sign-in link has been sent."
  end

  def show
    user = User.find_by_token_for(:email_login, params[:token])

    if user
      return_to = session.delete(:return_to).presence || root_path
      user.regenerate_login_nonce
      user.touch(:last_sign_in_at)
      reset_session
      session[:user_id] = user.id
      redirect_to return_to, notice: "Signed in as #{user.email}."
    else
      redirect_to login_path, alert: "That sign-in link is invalid or has expired."
    end
  end
end
