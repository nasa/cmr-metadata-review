namespace :legacy_ingest do

  desc "Imports legacy collection reviews from provided Excel Sheet"
  task :import_collections, [:filename] => :environment do |t, args|
    LegacyIngestor.new(args[:filename]).ingest_records!
  end

  desc "Imports legacy granule reviews from provided Excel Sheet"
  task :import_granules, [:filename] => :environment do |t, args|
    LegacyIngestor.new(args[:filename], true).ingest_records!
  end

end
