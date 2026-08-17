class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "bookings@mashuprockandrollmusical.com")
  layout "mailer"
end
