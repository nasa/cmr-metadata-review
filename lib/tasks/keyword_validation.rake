namespace :keyword_validation_cron do
  task :validate_keywords => :environment do
    require "#{Rails.root}/lib/rake_helpers/keyword_validation_helper"
    record_processed = KeywordValidation.validate_keywords
    Rails.logger.info("#{record_processed || 0} records validated.")
  end
end