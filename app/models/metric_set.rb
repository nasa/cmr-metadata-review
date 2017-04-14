# Metric Set Class
#
# The metric set class serves as an object that can generate predefined metric functions on an arbitrary set of records
# A MetricSet object is instantiated by providing an array of records as a parameter.
# Then all metrics are generated based on the given record set.
#
# A MetricSet containing the original revision of all records can also be instantiated from an existing MetricSet
# So a MetricSet with all revision "2" records will output a new MetricSet with all revision "1" records from the "original_record_set_function"


class MetricSet
  attr_accessor :record_set, :record_data_set
  @record_set = []
  @record_data_set = []

  def initialize(record_set = [])
    @record_set = record_set
    record_ids = @record_set.map { |record| record.id }
    @record_data_set = RecordData.all.select { |data| record_ids.include? data.record_id }
  end

  # ====Params   
  # Array of review objects 
  # ====Returns
  # Array of integers
  # ==== Method
  # Aggregates the number of reviews for each record in the record set, then returns the counts for each record in an Array

  def completed_review_counts(reviews)
    review_hash = {}
    #setting up review count hash
    @record_set.each do |record|
      review_hash[record.id] = 0
    end

    reviews.each do |review|
      if review_hash.key?(review.record_id)
        review_hash[review.record_id] = review_hash[review.record_id] + 1
      end
    end

    review_hash.values
  end  

  # ====Params   
  # None
  # ====Returns
  # List of 4 Integers representing flags
  # ==== Method
  # Then aggregates the counts of each flag type in record_data_set and returns a list of those values

  def color_counts
    blue_count = (@record_data_set.select { |data| data.color == "blue"}).count
    green_count = (@record_data_set.select { |data| data.color == "green"}).count
    yellow_count = (@record_data_set.select { |data| data.color == "yellow"}).count
    red_count = (@record_data_set.select { |data| data.color == "red"}).count
    [blue_count, green_count, yellow_count, red_count]
  end

  # ====Params   
  # None
  # ====Returns
  # Hash of counts for each flag type
  # ==== Method
  # Iterates through record_data_set summing for each flag the number of times a recorddata has that flag and is marked red

  def red_flags
    flagged_data = @record_data_set.select { |data| !data.flag.empty? && (data.color == "red") }

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
  # Aggregates the total number of records with their most recent revision_id record in a completed state.

  def total_completed
    (@record_set.select {|record| record.closed == true }).count
  end 

  # ====Params   
  # None    
  # ====Returns
  # Integer
  # ==== Method
  # Aggregates the total number of records with their most recent revision_id record in the in process state.

  def total_in_process
    (@record_set.select {|record| record.closed == false }).count
  end 

  # ====Params   
  # None     
  # ====Returns
  # Array of Floats
  # ==== Method
  # Iterates through record_list and for each done record, stores quality score in an Array


  def quality_done_records
    collection_records = @record_set.select { |record| record.closed }
    record_data_sets = collection_records.map { |record|  record.record_datas }
    scores = record_data_sets.map { |data_list| (1 - (data_list.select { |data| data.color == "red" }).count.to_f / (data_list.select { |data| data.color != "" }).count) * 100 }
    #adding at least one entry so that the average can shown if no records are closed.
    if scores.empty?
      scores.push(0)
    end

    scores
  end

  # ====Params   
  # None     
  # ====Returns
  # Hash {Integer => [Record]}
  # ==== Method
  # Finds the Collection for each record in record_set
  # Grabs a list of Collections for each record and then reduces to only unique Collections
  # Maps to each Collection Id, a list of related records, sorted newest to oldest


  def ordered_revisions
    concept_ids = []
    @record_set.each do |record|
      concept_ids.push(record.concept_id)
    end
    concept_ids.uniq!

    collections = concept_ids.map {|concept_id| Collection.find_by concept_id: concept_id }
    record_hash = {}

    collections.map do |collection|
      record_hash[collection.concept_id] = collection.records.sort { |x,y| y.id.to_i <=> x.id.to_i } 
    end

    record_hash
  end

  # ====Params   
  # None     
  # ====Returns
  # Integer
  # ==== Method
  # Obtains the ordered revisions list of lists
  # Iterates through the list summing the count of sublists where the first record is done and there is at least a second revision marked done

  def updated_done_count
    ordered_revisions = self.ordered_revisions.values
    updated_and_done = ordered_revisions.select { |record_list|
      record_list[0].closed && ((record_list.select { |record| record.closed }).count > 1)
    }

    updated_and_done.count
  end

  # ====Params   
  # None     
  # ====Returns
  # Integer
  # ==== Method
  # Obtains the ordered revisions list of lists
  # Iterates through the list summing count of sublists where there is a revision beyond the original one that is marked done.

  def updated_count
    ordered_revisions = self.ordered_revisions.values
    updated = ordered_revisions.select { |record_list|
      record_list.drop(1).count > 0
    }

    updated.count
  end


end