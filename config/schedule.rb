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
