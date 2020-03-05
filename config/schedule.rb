# Use this file to easily define all of your cron jobs.
#
set :output, 'log/session_cleanup_cron.log'
every 1.day, at: '4:00 am' do
  rake 'sessions_cleanup_cron:cleanup'
end

set :output, 'log/digest_emails.log'
every 30.minutes do
  rake 'daac_curator_emails_cron:send_emails'
end
