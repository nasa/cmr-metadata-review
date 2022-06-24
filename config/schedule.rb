# Use this file to easily define all of your cron jobs.

# Need to set the path so that the machine can find bundle to run the rake task
ruby_path = File.expand_path('..', %x(which ruby))
env :PATH, "#{ruby_path}:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin"

set :output, 'log/session_cleanup_cron.log'
every 1.day, at: '4:00 am' do
  rake 'sessions_cleanup_cron:cleanup'
end

set :output, 'log/digest_emails.log'
every 1.day, at: '2:00 am' do
  rake 'daac_curator_emails_cron:send_emails'
end
# Write job to the crontab:
# 'bundle exec whenever --update-crontab'
# Default env is production. To change that, run 'whenever --update-crontab --set environment='development''
# To verify crontab run 'crontab -l'
set :output, 'log/keyword_validation.log'
every 1.day, at: '4:00 am' do
  rake 'keyword_validation_cron:validate_keywords'
end
set :output, 'log/refresh_records.log'
#every 1.day, at: '3:00 am' do
every 15.minutes do
  rake 'refresh_records_cron:refresh_records'
end
