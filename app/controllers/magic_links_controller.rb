class MagicLinksController < ApplicationController
  rate_limit to: 5, within: 15.minutes, only: :create

  def create
    user = User.for_magic_link(params[:email])
    MagicLinkMailer.sign_in(user).deliver_now if user

    redirect_to sign_in_path, notice: "If that email is authorized, a sign-in link has been sent."
  end

  def show
    user = User.find_by_token_for(:magic_link, params[:token])

    if user
      user.regenerate_magic_link_nonce
      user.touch(:last_sign_in_at)
      reset_session
      session[:user_id] = user.id
      redirect_to root_path, notice: "Signed in as #{user.email}."
    else
      redirect_to sign_in_path, alert: "That sign-in link is invalid or has expired."
    end
  end
end
