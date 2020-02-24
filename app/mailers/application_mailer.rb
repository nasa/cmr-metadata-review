class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@cmr-dashboard.earthdata.nasa.gov'
  layout 'mailer'
end
