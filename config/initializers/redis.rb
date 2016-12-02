REDIS_CONFIG = YAML.load_file("#{Rails.root}/config/redis.yml")[Rails.env]
                 .slice('host', 'port', :db)
if Rails.env.production?
  REDIS_CONFIG = { url: ENV['REDIS_URL'] }
end
$redis ||= Redis.new(REDIS_CONFIG)