require 'dotenv/tasks'
desc 'refresh records'
namespace :refresh_records_cron do
  task refresh_records: :environment do
    user = ENV['cron_admin_user']
    unless user.nil?
      current_user = User.find_by(uid: user)
      added_records, deleted_records, failed_records = Cmr.update_collections(current_user)
      RefreshRecordsMailer.release_refreshed_records([current_user.email], added_records, failed_records, deleted_records).deliver_now
    end
  end
end
