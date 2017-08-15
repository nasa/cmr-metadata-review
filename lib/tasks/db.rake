# lib/tasks/db.rake
#https://gist.github.com/hopsoft/56ba6f55fe48ad7f8b90

namespace :db do

  desc "Dumps the database to db/APP_NAME.dump"
  task :dump_to_s3 => :environment do
    cmd = nil
    with_config do |app, host, db, user|
      cmd = "pg_dump --host #{host} --username #{user} --verbose --no-owner --no-acl --format=c #{db} > #{Rails.root}/db/#{app}.dump"
    end
    puts cmd
    %x{exec #{cmd}}

    backup_name = ""
    with_config do |app, host, db, user|
      s3 = Aws::S3::Resource.new
      backup_name = 'backup-' + db.to_s + '-' + Rails.env + '-' + DateTime.now.to_s 
      s3.bucket('arc-uah-cloud-prod').object(backup_name).upload_file(Rails.root.to_s + "/db/#{app}.dump")
    end
    puts backup_name
  end

  desc "Deletes the App DB and Restores the database dump at db/APP_NAME.dump."
  task :restore_from_local, [:task_pass] => :environment do |t, args|
    if args[:task_pass] != 'thisDeletesTheDatabase'
      puts 'No action taken, password required'
      next
    end

    cmd = nil
    with_config do |app, host, db, user|
      cmd = "pg_restore --verbose --host #{host} --username #{user} --clean --no-owner --no-acl --dbname #{db} #{Rails.root}/db/cmr_metadata_review.dump"
    end

    #this will delete the current app DB contents
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    puts cmd
    exec cmd
  end

  private

  def with_config
    yield Rails.application.class.parent_name.underscore,
      ActiveRecord::Base.connection_config[:host],
      ActiveRecord::Base.connection_config[:database],
      ActiveRecord::Base.connection_config[:username]
  end

end