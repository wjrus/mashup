class LoginMailer < ApplicationMailer
  def sign_in(user)
    @user = user
    @login_url = verify_login_url(token: user.generate_token_for(:email_login))

    mail(to: user.email, subject: "Your MATCH Bookings sign-in link")
  end
end
