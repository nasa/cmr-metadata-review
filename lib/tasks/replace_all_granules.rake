#this task needed for the merge of code to add granules functionality.
#granules had been imported with incorrect import code since the granules were being unused
#granules need to be reimported with correct code to prep for review.

task :replace_all_granules => :environment do
  all_collections = Collection.all.to_a
  collections_with_record = all_collections.select {|collection| collection.get_records.count > 0 }

  # Deleting all granules
  Granule.destroy_all

  ingester = User.find_by(email: 'jeanne.leroux@nsstc.uah.edu')

  collections_with_record.each do |collection|
    collection.add_granule(ingester)
  end
end
