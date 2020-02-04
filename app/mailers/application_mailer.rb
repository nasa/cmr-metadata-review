class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@cmr-dashboard.nasa.gov'
  layout 'mailer'
end
