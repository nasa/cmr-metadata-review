namespace :daac_curator_emails_cron do
  task :send_emails => :environment do
    number_sent = User.released_records_digest_conductor
    Rails.logger.info("#{number_sent || 0} digest e-mails sent to daac curators during cron task.")
  end
end

