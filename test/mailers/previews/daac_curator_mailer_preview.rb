class DaacCuratorMailerPreview < ActionMailer::Preview
  def released_records_digest_notification
    mail = ''
    ActiveRecord::Base.transaction do
      collection = Collection.new(id: 1_000_000, concept_id: '')
      collection.save
      granule = Granule.new(id: 1_000_001, concept_id: '', collection_id: 1_000_000)
      granule.save
      user1 = User.new(email: 'fake@fake.com', name: 'Fakey Faker')
      user2 = User.new(email: 'fake2@fake.com', name: 'Faker Fake')
      record1 = Record.new(id: 1_000_000, recordable_type: 'Collection', recordable_id: 1_000_000, revision_id: 1, released_to_daac_date: 4.days.ago)
      record1.record_datas = [RecordData.new(record_id: 1_000_000, column_name: 'ShortName', value: 'A Sample Record')]
      record2 = Record.new(id: 1_000_001, recordable_type: 'Granule', recordable_id: 1_000_001, revision_id: 1, released_to_daac_date: 1.days.ago)
      record2.record_datas = [RecordData.new(record_id: 1_000_001, column_name: 'GranuleUR', value: 'A really really really really really really really really really really really really really really really really really really really really really really really really long title')]
      record1.save
      record2.save

      mail = DaacCuratorMailer.released_records_digest_notification([user1, user2], [record1, record2], 'OB_DAAC')
      record1.delete
      record2.delete
      granule.delete
      collection.delete
    end
    mail
  end
end