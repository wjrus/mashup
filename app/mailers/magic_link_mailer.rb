class MagicLinkMailer < ApplicationMailer
  def sign_in(user)
    @user = user
    @magic_link_url = magic_link_url(token: user.generate_token_for(:magic_link))

    mail(to: user.email, subject: "Your Mashup Bookings sign-in link")
  end
end
