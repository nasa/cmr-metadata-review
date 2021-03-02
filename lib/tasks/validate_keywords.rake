desc 'validate keywords'
task :validate_keywords => :environment do |task, args| 
    record_processed = KeywordValidator.validate_keywords
    Rails.logger.info("#{record_processed || 0} records validated.")
end
                         
