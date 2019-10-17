# in order for this to work, you need to modify cmr.rb get_cmr_base_url so it
# returns the production url.  
# todo: make it work with environment = prod, might just need secret token,
# was complaining about that.

task :load_collection_granules => :environment do
  array = ["C204582034-LPDAAC_ECS/61","C1000000100-LPDAAC_ECS/74"]

  array.each do |str|
    concept_id, revision_id = str.split('/')
    puts "Processing #{concept_id}/#{revision_id}"
    raw = Cmr.get_raw_concept(concept_id, revision_id)
    File.write("/tmp/records/#{concept_id}_#{revision_id}.raw", raw)
    result = Cmr.random_granules_from_collection(concept_id).first
    granule_concept_id = result['concept_id']
    granule_revision_id = result['revision_id']
    raw = Cmr.get_raw_concept(granule_concept_id, granule_revision_id)
    File.write("/tmp/records/#{concept_id}_#{revision_id}_#{granule_concept_id}_#{granule_revision_id}", raw)
  end
end
