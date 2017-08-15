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

  desc "Restores the database dump at db/APP_NAME.dump."
  task :restore_from_s3, [:db_filename] => :environment do |t, args|
    next if args[:db_filename].nil?

    s3 = Aws::S3::Client.new
    File.open('s3_dump.dump', 'wb') do |file|
      reap = s3.get_object({ bucket:'arc-uah-cloud-prod', key:args[:db_filename] }, target: file)
    end

    cmd = nil
    with_config do |app, host, db, user|
      cmd = "pg_restore --verbose --host #{host} --username #{user} --clean --no-owner --no-acl --dbname #{db} #{Rails.root}/s3_dump.dump"
    end

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