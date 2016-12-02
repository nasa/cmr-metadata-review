require 'resolv-replace'
require "sidekiq/web"
require 'sidekiq/cron/web'

# https://github.com/mperham/sidekiq/issues/2487
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_token]

# All redis config are stored in resque.yml
sidekiq_config = YAML.load_file("config/sidekiq.yml") if File.exists?("config/sidekiq.yml")
sidekiq_db = sidekiq_config[:db]

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{REDIS_CONFIG['host']}:#{REDIS_CONFIG['port']}/#{sidekiq_db}" }

  schedule_file = "config/schedule.yml"

  if File.exists?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{REDIS_CONFIG['host']}:#{REDIS_CONFIG['port']}/#{sidekiq_db}" }
end

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == sidekiq_config[:username] && Digest::SHA1.hexdigest(password) == sidekiq_config[:password]
end

Sidekiq.default_worker_options = { 'queue' => 'default', 'backtrace' => true, 'retry' => 3 }

# Require all sidekiq worker & scheduled_job classes
%W(background_workers cron_jobs).each do |dir|
  Dir["#{Rails.root}/app/#{dir}/*.rb"].each do |filename|
    require "#{filename}"
  end
end

# Clear all the queues in the development environment
if Rails.env.development?

  sidekiq_config[:queues].each do |key, val|
    Sidekiq::Queue.new(key).clear
  end

  Sidekiq::ScheduledSet.new.clear
  Sidekiq::RetrySet.new.clear
end

