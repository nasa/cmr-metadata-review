#Record is the ActiveRecord representation of a record retrieved from the CMR
#An individual record can be identified by a unique concept-id and revision-id combination
#Record is a child of both Collection and Granule

class Record < ActiveRecord::Base
  include AASM
  include RecordHelper

  after_initialize :load_format_module

  has_many :record_datas
  belongs_to :recordable, :polymorphic => true
  has_many :reviews
  has_one :ingest
  has_many :discussions

  scope :daac, ->(daac) { joins(:record_datas).where(record_data: { daac: daac }).distinct }

  REVIEW_ERRORS = {
    color_coding_complete?: "Not all columns have been flagged with a color, cannot close review.",
    has_enough_reviews?: "A review needs two completed reviews to be closed, cannot close review.",
    no_second_opinions?: "Some columns still need a second opinion review, cannot close review.  Please clear all second opinion flags.",
    granule_completed?: "The Collection's related Granule must be marked complete before the Collection can be completed."
  }

  aasm column: 'state', whiny_persistence: false do
    state :open, initial: true
    state :in_arc_review, :ready_for_daac_review, :in_daac_review, :closed, :hidden

    event :start_arc_review do
      transitions from: :open, to: :in_arc_review
    end

    event :complete_arc_review do
      transitions from: :in_arc_review, to: :ready_for_daac_review, guards: [:color_coding_complete?, :has_enough_reviews?, :no_second_opinions?, :granule_completed?]
    end

    event :release_to_daac do
      transitions from: :ready_for_daac_review, to: :in_daac_review
    end

    event :close do
      before do
        write_attribute(:closed_date, ::DateTime.now)
      end

      transitions from: :in_daac_review, to: :closed
    end

    event :hide do
      transitions from: [:open, :in_arc_review, :ready_for_daac_review, :in_daac_review, :closed], to: :hidden
    end
  end

  def load_format_module
    if self.format == "dif10"
      self.extend(Modules::RecordFormats::Dif10Record)
    else
      self.extend(Modules::RecordFormats::Echo10Record)
    end
  end

  # ====Params
  # None
  # ====Returns
  # Boolean
  # ==== Method
  # Returns true if this record is an attribute of a Collection
  def is_collection?
    self.recordable_type == "Collection"
  end

  # ====Params
  # None
  # ====Returns
  # Boolean
  # ==== Method
  # Returns true if this record is an attribute of a Granule
  def is_granule?
    self.recordable_type == "Granule"
  end

  # ====Params
  # None
  # ====Returns
  # String
  # ==== Method
  # Accesses the record's RecordData attribute and then returns the value of the param field
  def get_column(column_name)
    column = self.record_datas.where(column_name:column_name).first
    if column
      column.value
    else
      ""
    end
  end


  # ====Params
  # None
  # ====Returns
  # String
  # ==== Method
  # Lookes up the Ingest object related to this record, then returns the email of the user associated with the Ingest
  def ingested_by
    begin
      self.ingest.user.email
    rescue
      "None"
    end
  end


  # ====Params
  # None
  # ====Returns
  # Hash
  # ==== Method
  # Returns a Hash with the key value pairs of "column_name" => "metadata value" for the record
  def values
    values_hash = {}
    self.record_datas.each do |data|
      values_hash[data.column_name] = data.value
    end

    values_hash
  end

  def get_previous_revision
    # a set of fellow records sorted by revision id in ascending order
    collection_records = self.recordable.records.order(:revision_id).to_a
    self_index = collection_records.index { |record| record.revision_id == self.revision_id }
    # self is first revision id or is not found
    if self_index < 1
      nil
    else
      collection_records[(self_index - 1)]
    end
  end

  def previous_values
    previous_record = self.get_previous_revision
    if previous_record.nil?
      {}
    else
      previous_record.values
    end
  end

  def previous_recommendations
    previous_record = self.get_previous_revision
    if previous_record.nil?
      {}
    else
      previous_record.get_recommendations
    end
  end

  # ====Params
  # None
  # ====Returns
  # String
  # ==== Method
  # Helper to return the state of a record in String form
  # Returns "In Process" or "Completed"
  # When records are complete, no further reviews or changes to review data can be added
  def status_string
    if self.closed?
      "Completed"
    else
      "In Process"
    end
  end


  # ====Params
  # None
  # ====Returns
  # String
  # ==== Method
  # Accesses the Collection or Granule that this record is an attribute of and returns its concept_id
  def concept_id
    self.recordable.concept_id
  end


  def get_raw_data
    if is_collection?
      Cmr.get_raw_collection(concept_id)
    else
      Cmr.get_raw_granule(concept_id)
    end
  end


  # ====Params
  # Hash from automated script output,
  # List of keys in record data
  # ====Returns
  # Hash of recordData values
  # ==== Method
  # This method takes the raw output of the automated script, and attaches it
  # to a recordData value hash
  # Method is necessary because automated script will only produce one result for
  # "Platforms/Platform/ShortName" etc.
  # and the recordData hash needs that result connected to all platform keys
  # "Platforms/Platform0/ShortName", "Platforms/Platform1/ShortName" etc
  def self.format_script_comments(comment_hash, value_keys)
    comment_keys = comment_hash.keys

    comment_keys.each do |comment_field|
      value_keys.each do |value_field|
        #the regex here takes the comment key and checks if the value key is the same, but with 0-9 digits included.
        #if so, it adds the comment value to the fields.
        #so "Platforms/Platform/ShortName" value gets added to "Platforms/Platform0/ShortName"
        if value_field =~ /#{(comment_field.split('/').reduce("") {|sum, n| sum + '/' + n + '[0-9+]?'  })[1..-1]}/
          comment_hash[value_field] = comment_hash[comment_field]
        end
      end
    end

    return comment_hash
  end

  # ====Params
  # String
  # ====Returns
  # Hash of "column_names" => "field_values"
  # ==== Method
  # The general method for retreiving column => field hashes from a record
  def get_field(field_name)
    record_datas = self.sorted_record_datas
    fields = {}
    record_datas.each do |data|
      fields[data.column_name] = data[field_name]
    end
    fields
  end

  # ====Params
  # None
  # ====Returns
  # Hash of "column_names" => "color_values"
  # ==== Method
  # This method looks up the record's associated Color values.
  def get_colors
    get_field("color")
  end


  # ====Params
  # None
  # ====Returns
  # Hash of "column_names" => "script_values"
  # ==== Method
  # This method looks up the record's associated script_comment values.
  def get_script_comments
    get_field("script_comment")
  end

  # ====Params
  # None
  # ====Returns
  # Hash of "column_names" => "recommendation_values"
  # ==== Method
  # This method looks up the record's associated recommendation values.
  def get_recommendations
    get_field("recommendation")
  end

  # ====Params
  # None
  # ====Returns
  # Hash of "column_names" => "opinion_values"
  # ==== Method
  # This method looks up the record's associated opinion values.
  def get_opinions
    get_field("opinion")
  end

  # ====Params
  # None
  # ====Returns
  # Hash of "column_names" => "feedback (true/false)"
  # ==== Method
  # This method looks up the record's associated feedback request values.
  def get_feedbacks
    get_field("feedback")
  end

  # ====Params
  # Hash
  # ====Returns
  # Integer
  # ==== Method
  # Method takes a param of a hash of "field_name" => "script output string" pairs
  # Each value of the Hash is checked for containing any variation of the string "ok"
  # Each value containing the string is counted as a point, the total points for the whole hash is returned.
  def score_script_hash(script_hash)
    score = 0
    script_hash.each do |key, sub_value|
      if script_hash[key].is_a?(String)
        if (sub_value.include? "OK") || (sub_value.include? "ok") || (sub_value.include? "Ok")
          score = score + 1
        end
      end
    end
    score
  end


  def update_recommendations(partial_hash)
    any_data_changed = false
    if partial_hash
      partial_hash.each do |key, value|
          data = RecordData.where(record: self, column_name: key).first
          if data
            if data.recommendation != value
              any_data_changed = true
            end
            data.recommendation = value
            data.save
          end
      end
    end

    any_data_changed
  end


  def update_colors(partial_hash)
    any_data_changed = false
    if partial_hash
      partial_hash.each do |key, value|
          data = RecordData.where(record: self, column_name: key).first
          if data
            if data.color != value
              any_data_changed = true
            end
            data.color = value
            data.save
          end
      end
    end
    any_data_changed
  end

  def update_opinions(opinions_hash)
    any_data_changed = false
    if opinions_hash
      opinions_hash.each do |key, value|
          data = RecordData.where(record: self, column_name: key).first
          if data
            if data.opinion != value
              any_data_changed = true
            end
            data.opinion = value
            data.save
         end
      end
    end
  end

  def update_feedbacks(feedbacks_hash)
    any_data_changed = false
    if feedbacks_hash
      feedbacks_hash.each do |key, value|
          data = RecordData.where(record: self, column_name: key).first
          if data
            if data.feedback != value
              any_data_changed = true
            end

            data.feedback = value
            data.save
         end
      end
    end
  end

  # ====Params
  # None
  # ====Returns
  # Hash
  # ==== Method
  # Accesses the record's automated script results and then returns the "field_name" => "value" pairs in a hash
  def script_values
    self.get_script_comments
  end

  # ====Params
  # None
  # ====Returns
  # Integer
  # ==== Method
  # Returns the score originally generated in #score_script_hash method
  # No further processing is done as this method accesses the score as a stored attribute
  def script_score
    0
  end



  def add_script_comment(script_hash)
    script_hash.each do |key, value|
      record_data = self.record_datas.where(column_name: key).first
      if record_data
        record_data.script_comment = value
        record_data.save
      end
    end
  end

  def add_review(user_id)
    new_review = Review.new
    new_review.record = self
    new_review.user_id = user_id
    new_review.review_state = 0
    new_review.save!

    return new_review
  end

  def bubble_data
    bubble_set = []
    # setting flag data
    record_colors = self.get_colors
    bubble_set = record_colors.keys.map do |field|
      if record_colors[field] == ""
        bubble_color = "white"
      else
        bubble_color = record_colors[field]
      end

      { :field_name => field, :color => bubble_color }
    end

    # adding the automated script results to each bubble
    binary_script_values = self.binary_script_values

    if binary_script_values.empty?
      bubble_set = bubble_set.map { |bubble| bubble[:script] = false }
    else
      bubble_set = bubble_set.map do |bubble|
        bubble[:script] = binary_script_values[bubble[:field_name]]
        bubble
      end
    end

    #adding the second opinions
    opinion_values = self.get_opinions
    bubble_set = bubble_set.map do |bubble|
      bubble[:opinion] = opinion_values[bubble[:field_name]]
      bubble
    end

    bubble_set
  end

  def bubble_map
    bubble_set = self.bubble_data
    bubble_map = {}
    begin
      bubble_set.each {|bubble| bubble_map[bubble[:field_name]] = bubble}
    rescue
      bubble_map = {}
    end
    bubble_map
  end

  def color_coding_complete?
    if ENV['SIT_SKIP_DONE_CHECK'] == 'true'
      return true
    end

    colors = self.get_colors

    colors.each do |key, value|
      if value == nil || !(value == "green" || value == "blue" || value == "yellow" || value == "red")
        return false
      end
    end

    return true
  end

  def completed_review_count
    return (self.reviews.select {|review| review.completed?}).count
  end

  def has_enough_reviews?
    if ENV['SIT_SKIP_DONE_CHECK'] == 'true'
      return true
    end

    return self.completed_review_count > 1
  end

  def no_second_opinions?
    if ENV['SIT_SKIP_DONE_CHECK'] == 'true'
      return true
    end

    return !(self.get_opinions.select {|key,value| value == true}).any?
  end

  def granule_completed?
    if ENV['SIT_SKIP_DONE_CHECK'] == 'true'
      return true
    end

    if self.is_granule? ||
       self.recordable.try(:granules).nil? ||
       (self.recordable.granules.count == 0) ||
       (self.recordable.granules.first.records.first.nil?) ||
       (self.recordable.granules.first.records.first.closed?)

      return true
    end

    return false
  end

  def second_opinion_count
    opinion_values = self.get_opinions
    return opinion_values.values.reduce(0) {|sum, value| value == true ? (sum + 1): sum }
  end


  # def close
  #   self.closed = true
  #   self.closed_date = DateTime.now
  #   self.save
  # end

  def formatted_closed_date
    #01/19/2017 at 01:55PM (example format)
    if self.closed_date.nil?
      return ""
    else
      return self.closed_date.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d/%Y at %I:%M%p")
    end
  end

  def review(user_id)
    review = Review.where(record: self, user_id: user_id).first
    if review.nil?
      review = Review.new(record: self, user_id: user_id, review_state: 0)
    end

    review
  end

  def binary_script_values
    script_values = self.script_values
    # replaces the values in the hash with true/false depending on the script test helper
    binary_script_values = script_values.map { |key, val| [key, script_test(val)] }.to_h
    binary_script_values
  end

  #should return a list where each entry is a (title,[title_list])
  def sections
    section_list = []

    get_section_titles.each do |title|
      section_list += self.get_section(title)
    end

    used_titles = (section_list.map {|section| section[1]}).flatten
    all_titles = self.sorted_record_datas.map { |data| data.column_name }

    others = [["Collection Info", all_titles.select {|title| !used_titles.include? title }]]

    section_list = others + section_list
  end

  def get_section(section_name)
    section_list = []
    all_titles = self.sorted_record_datas.map { |data| data.column_name }
    one_section = all_titles.select {|title| title.match /^#{section_name}\//}
    if one_section.any?
      return [[section_name, one_section]]
    else
      count = 0
      while (all_titles.select {|title| title.match /^#{section_name}#{count.to_s}\//}).any?
        next_section = all_titles.select {|title| title.match /^#{section_name}#{count.to_s}\//}
        section_list.push([section_name + count.to_s, next_section])
        count = count + 1
      end
      section_list
    end
  end

  def color_codes
    self.get_colors
  end

  def color_count(color_name)
    (self.record_datas.select {|data| data.color == color_name }).count
  end

  def sorted_record_datas
    self.record_datas.sort_by { |data| data.order_count }
  end

  def has_short_name?
    self.short_name != ""
  end

  def daac
    self.concept_id.partition('-').last
  end

  def cmr_update?
    self.recordable.update?
  end

  def update_from_review(current_user, section_index, new_recommendations, new_colors, new_opinions, new_discussions, new_feedbacks, new_feedback_discussions)
    section_index = section_index.to_i

    if section_index.nil?
      return -1
    end

    section_titles = self.sections[section_index][1]

    #this is so that no review is created unless the input some data into the review
    any_data_changed = false

    begin
      if self.update_recommendations(new_recommendations)
        any_data_changed = true
      end

      if self.update_colors(new_colors)
        any_data_changed = true
      end

      opinion_values = self.get_opinions
      section_titles.each do |title|
        opinion_values[title] = false
      end

      if new_opinions
        new_opinions.each do |key, value|
            if value == "on"
              opinion_values[key] = true
            end
        end
      end

      self.update_opinions(opinion_values)

      feedback_values = self.get_feedbacks
      section_titles.each do |title|
        feedback_values[title] = false
      end

      if new_feedbacks
        new_feedbacks.each do |key, value|
          if value == "on"
            feedback_values[key] = true
          end
        end
      end

      self.update_feedbacks(feedback_values)

      if new_discussions
        new_discussions.each do |key, value|
          if value != ""
            any_data_changed = true
            message = Discussion.new(record: self, user: current_user, column_name: key, date: DateTime.now, comment: value)
            message.save
          end
        end
      end

      if new_feedback_discussions
        new_feedback_discussions.each do |key, value|
          if value != ""
            any_data_changed = true
            message = Discussion.new(record: self, user: current_user, column_name: key, date: DateTime.now, comment: value, category: DiscussionCategory::FEEDBACK)
            message.save
          end
        end
      end
    rescue
      return -1
    end

    any_data_changed
  end

  def update_legacy_data(column_name, data)
    record_data = record_datas.find_by(column_name: column_name)
    record_data.update_attributes(data) if record_data
  end

  def umm_json_link
    "https://cmr.earthdata.nasa.gov/search/concepts/#{self.concept_id}/#{self.revision_id}.umm-json"
  end

  def native_link
    "https://cmr.earthdata.nasa.gov/search/concepts/#{self.concept_id}/#{self.revision_id}.native"
  end

  def related_granule_record
    if self.is_granule?
      return nil
    end

    collection = self.recordable
    granule = collection.granules.first
    if granule
      granule_record = (granule.records.sort { |x,y| y.id.to_i <=> x.id.to_i }).first
      return granule_record
    end

    nil
  end

end
