# https://stackoverflow.com/questions/24927928/singleton-in-scope-of-a-request-in-rails
# Since each request is tied to a thread, we are storing user info in the thread local store
# as a singleton.   Cmr.rb is called from models, controllers, helpers, etc.
# It would take a major refactoring to make the User info available at all these layers.
# Ideally, we would need some kind of Environment object which is passed down through.
# That is essentially what the thread local store is providing us.   But it would be better
# to refactor Cmr.rb and really think about all the interactions with it.
#
class UserSingleton
  attr_accessor :current_user
  @current_user = nil

  def self.instance
    Thread.current['user-singleton'] ||= UserSingleton.new
  end

  def echo_token
    "#{@current_user.access_token}:#{ENV['urs_client_id']}"
  end

  def self.clear
    singleton = Thread.current['user-singleton']
    unless singleton.nil?
      user = singleton.current_user
      puts "clearing #{user.uid}" unless user.nil?
    end
    Thread.current['user-singleton'] = nil
  end
end