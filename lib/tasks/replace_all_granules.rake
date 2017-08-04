task :replace_all_granules => :environment do
  all_collections = Collection.all.to_a
  collections_with_record = all_collections.map {|collection| collection.get_records.count > 0 }

  collections_with_record.each do |collection|
    collection.remove_all_granule_data
    collection.add_granule(nil)
  end
end