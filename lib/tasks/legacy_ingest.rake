namespace :legacy_ingest do

  desc "Imports legacy collection reviews from provided Excel Sheet"
  task :import_collections, [:filename] => :environment do |t, args|
    LegacyIngestor.new(args[:filename]).ingest_records!
  end

  desc "Imports legacy granule reviews from provided Excel Sheet"
  task :import_granules, [:filename] => :environment do |t, args|
    LegacyIngestor.new(args[:filename], granules: true).ingest_records!
  end

  desc "Imports an 'in-progress' review sheet"
  task :import_in_progress_collections, [:filename] => :environment do |t, args|
    LegacyIngestor.new(args[:filename], in_progress: true).ingest_records!
  end

  desc "Imports an 'in-progress' granule review sheet"
  task :import_in_progress_granules, [:filename] => :environment do |t, args|
    LegacyIngestor.new(args[:filename], granules: true, in_progress: true).ingest_records!
  end
end
