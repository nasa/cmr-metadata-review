class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@#{Rails.configuration.default_email_domain}"
  # Lambda to construct unique message ids for each mail.
  default 'Message-ID' => -> { "<#{SecureRandom.uuid}@#{Rails.configuration.default_email_domain}>" }
  layout 'mailer'
end
