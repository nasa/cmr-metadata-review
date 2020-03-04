namespace :daac_curator_emails_cron do
  task :send_emails => :environment do
    require "#{Rails.root}/lib/rake_helpers/daac_curator_mailer_helper"
    number_sent = DaacCuratorMailerOrchestration.released_records_digest_conductor
    Rails.logger.info("#{number_sent || 0} digest e-mails sent to daac curators during cron task.")
  end
end

