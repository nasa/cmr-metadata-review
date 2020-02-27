class DaacCuratorMailerPreview < ActionMailer::Preview
  def released_records_digest_notification
    user1 = User.new(email: 'fake@fake.com', name: 'Fakey Faker')
    user2 = User.new(email: 'fake2@fake.com', name: 'Faker Fake')
    record1 = Record.new(id: 1_000_000, recordable_type: 'Collection', recordable_id: 1_000_000, revision_id: 1, released_to_daac_date: 4.days.ago)
    record1.record_datas = [RecordData.new(record_id: 1_000_000, column_name: 'LongName', value: 'A Sample Record')]
    record2 = Record.new(id: 1_000_001, recordable_type: 'Granule', recordable_id: 1_000_001, revision_id: 1, released_to_daac_date: 1.days.ago)
    record2.record_datas = [RecordData.new(record_id: 1_000_001, column_name: 'GranuleUR', value: 'A really really really really really really really really really really really really really really really really really really really really really really really really long title')]

    DaacCuratorMailer.released_records_digest_notification([user1, user2], Record.first(5), 'OB_DAAC')
  end
end