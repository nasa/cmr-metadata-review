class MetricSet
  @record_set = []

  def initialize(record_set = [])
    @record_set = record_set
  end

  # ====Params   
  # String, DAAC Short Name  
  # ====Returns
  # Hash of {record id's => completed review counts}
  # ==== Method
  # Takes all of the newest revisions for entire system or by DAAC
  # Then creates a hash of each collection and the corresponding counts of completed reviews

  def completed_review_counts
    review_hash = {}
    completed_reviews = Review.all.where(review_state: 1)  
    #setting up review count hash
    @record_set.each do |record|
      review_hash[record.id] = 0
    end

    completed_reviews.each do |review|
      if review_hash.key?(review.record_id)
        review_hash[review.record_id] = review_hash[review.record_id] + 1
      end
    end

    review_hash.values
  end  

  # ====Params   
  # String, DAAC Short Name  
  # ====Returns
  # List of 4 Integers representing flags
  # ==== Method
  # First the method gets a list of all newest revision records, then finds all RecordData that corresponds to any record in the list
  # Then aggregates the counts of each flag type and returns a list of those values

  def color_counts
    record_ids = @record_set.map { |record| record.id }
    record_datas = RecordData.all.select { |data| record_ids.include? data.record_id }
    
    blue_count = (record_datas.select { |data| data.color == "blue"}).count
    green_count = (record_datas.select { |data| data.color == "green"}).count
    yellow_count = (record_datas.select { |data| data.color == "yellow"}).count
    red_count = (record_datas.select { |data| data.color == "red"}).count

    [blue_count, green_count, yellow_count, red_count]
  end

  # ====Params   
  # String, DAAC Short Name  
  # ====Returns
  # Hash of counts for each flag type
  # ==== Method
  # Obtains the complete set of RecordData elements related to the newest revision of each collection
  # Iterates through that list summing for each flag the number of times a recorddata has that flag and is marked red

  def red_flags
    record_ids = @record_set.map { |record| record.id }
    record_datas = RecordData.all.select { |data| record_ids.include? data.record_id }

    flagged_data = record_datas.select { |data| !data.flag.empty? && (data.color == "red") }

    flag_hash = { "Accessibility" => 0, "Traceability" => 0, "Usability" => 0 }
    flagged_data.each do |data|
      data.flag.each do |flag_name|
        flag_hash[flag_name] = flag_hash[flag_name] + 1
      end
    end

    flag_hash
  end


  # ====Params   
  # None    
  # ====Returns
  # Integer
  # ==== Method
  # Aggregates the total number of Collections with their most recent revision_id record in a completed state.

  def total_completed
    (@record_set.select {|record| record.closed == true }).count
  end 

  # ====Params   
  # None    
  # ====Returns
  # Integer
  # ==== Method
  # Aggregates the total number of Collections with their most recent revision_id record in the in process state.

  def total_in_process
    newest_record_list = Collection.all_newest_revisions
    (@record_set.select {|record| record.closed == false }).count
  end 

  def quality_done_records
    collection_records = @record_set.select { |record| record.closed }

    record_data_sets = collection_records.map { |record|  record.record_datas }
    scores = record_data_sets.map { |data_list| (1 - (data_list.select { |data| data.color == "red" }).count.to_f / (data_list.select { |data| data.color != "" }).count) * 100 }
    scores
  end

  def ordered_revisions
    concept_ids = []
    @record_set.each do |record|
      concept_ids.push(record.concept_id)
    end
    concept_ids.uniq!

    collections = concept_ids.map {|concept_id| Collection.find_by concept_id: concept_id }
    record_hash = {}

    collections.map do |collection|
      record_hash[collection.concept_id] = collection.records.sort_by(&:id)
    end

    record_hash
  end

  # ====Params   
  # String, name of provider     
  # ====Returns
  # Integer
  # ==== Method
  # Obtains the ordered revisions list of lists
  # Iterates through the list summing the count of sublists where the first record is done and there is at least a second revision marked done

  def updated_done_count(daac_short_name = nil)
    ordered_revisions = self.ordered_revisions.values
    updated_and_done = ordered_revisions.select { |record_list|
      record_list[0].closed && ((record_list.select { |record| record.closed }).count > 1)
    }

    updated_and_done.count
  end

  # ====Params   
  # String, name of provider     
  # ====Returns
  # Integer
  # ==== Method
  # Obtains the ordered revisions list of lists
  # Iterates through the list summing count of sublists where there is a revision beyond the original one that is marked done.

  def updated_count(daac_short_name = nil)
    ordered_revisions = self.ordered_revisions.values
    updated = ordered_revisions.select { |record_list|
      record_list.drop(1).count > 0
    }

    updated.count
  end


end