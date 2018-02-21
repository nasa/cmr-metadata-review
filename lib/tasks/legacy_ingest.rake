namespace :legacy_ingest do

  desc "Imports legacy collection reviews from provided Excel Sheet"
  task :import_collections, [:filename, :daac] => :environment do |t, args|
    LegacyIngestor.new(args[:filename], args[:daac]).ingest_records!
  end

  desc "Imports legacy granule reviews from provided Excel Sheet"
  task :import_granules, [:filename, :daac] => :environment do |t, args|
    LegacyIngestor.new(args[:filename], args[:daac], true).ingest_records!
  end

end
