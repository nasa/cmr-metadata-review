# Use this file to easily define all of your cron jobs.
#
set :output, "/tmp/cron_log.log"
every 1.day, at: '4:00 am' do
  rake "db:sessions:trim"
end
