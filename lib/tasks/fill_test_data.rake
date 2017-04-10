task :fill_test_data => :environment do

  PROVIDERS = ['PODAAC', 'SEDAC', 'OB_DAAC', 'ORNL_DAAC', 'NSIDC_ECS', 'LAADS',
              'LPDAAC_ECS', 'GES_DISC','CDDIS', 'LARC_ASDC','ASF','GHRC'
              ]

  collection_count = 300
  record_count = 500
  record_data_count = 10000



  added_collections = []

  (0..collection_count).each do |num|
    daac_name = PROVIDERS.sample
    col = Collection.new(concept_id: ("test_id-#{num}#{daac_name}"), short_name: ("test_short_name#{num}"))
    col.save
    added_collections.push(col)
  end

  added_records = []

  added_collections.each do |collection|
    rec = Record.new(recordable: collection, revision_id: "-1")
    if Random.rand(11) > 5 
      rec.closed = true
      rec.closed_date = DateTime.now
      rec.save
      review = Review.new(record: rec, user_id: 1, review_completion_date: DateTime.now, review_state: 1)
      review.save

      review2 = Review.new(record: rec, user_id: 2, review_completion_date: DateTime.now, review_state: 1)
      review2.save

    else
      rec.closed = false
      rec.save

      rando = Random.rand(11)
      if rando > 9
          review = Review.new(record: rec, user_id: 1, review_completion_date: DateTime.now, review_state: 1)
          review.save

          review2 = Review.new(record: rec, user_id: 2, review_completion_date: DateTime.now, review_state: 1)
          review2.save
      elsif rando > 4
          review = Review.new(record: rec, user_id: 1, review_completion_date: DateTime.now, review_state: 1)
          review.save
      end
    end

    added_records.push(rec)
  end 


  (0..record_count).each do |num|
    rec = Record.new(recordable: added_collections.sample, revision_id: num.to_s)
    if Random.rand(11) > 5 
      rec.closed = true
      rec.closed_date = DateTime.now
      rec.save
      review = Review.new(record: rec, user_id: 1, review_completion_date: DateTime.now, review_state: 1)
      review.save

      review2 = Review.new(record: rec, user_id: 2, review_completion_date: DateTime.now, review_state: 1)
      review2.save

    else
      rec.closed = false
      rec.save

      rando = Random.rand(11)
      if rando > 9
          review = Review.new(record: rec, user_id: 1, review_completion_date: DateTime.now, review_state: 1)
          review.save

          review2 = Review.new(record: rec, user_id: 2, review_completion_date: DateTime.now, review_state: 1)
          review2.save
      elsif rando > 4
          review = Review.new(record: rec, user_id: 1, review_completion_date: DateTime.now, review_state: 1)
          review.save
      end
    end

    added_records.push(rec)
  end


  added_records.each do |record|
    data = RecordData.new(record: record, value: "test_val", column_name: "VersionId")
    colors = ["blue", "green", "yellow", "red"]
    rand_color = Random.rand(4)
    data.color = colors[rand_color]
    if rand_color == 3
      rand_flag = Random.rand(3)
      flags = ["Accessibility", "Traceability", "Usability"]
      data.flag = [flags[rand_flag]]
    end
    data.save


    ingest = Ingest.new(record: record, user_id: 1, date_ingested: DateTime.now)
    ingest.save
  end


  (0..record_data_count).each do |num|
    data = RecordData.new(record: added_records.sample, value: "test_val#{num}", column_name: "test_name#{num}")
    colors = ["blue", "green", "yellow", "red"]
    rand_color = Random.rand(4)
    data.color = colors[rand_color]
    if rand_color == 3
      rand_flag = Random.rand(3)
      flags = ["Accessibility", "Traceability", "Usability"]
      data.flag = [flags[rand_flag]]
    end

    if Random.rand(1) == 1
      data.opinion = true
    else
      data.opinion = false
    end
    data.save
  end

end