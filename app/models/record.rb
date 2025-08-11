# Record is the ActiveRecord representation of a record retrieved from the CMR
# An individual record can be identified by a unique concept-id and revision-id combination
# Record is a child of both Collection and Granule

class Record < ApplicationRecord
  include AASM
  include RecordHelper

  after_initialize :load_format_module

  has_many :record_datas, dependent: :destroy
  belongs_to :recordable, :polymorphic => true
  has_many :reviews
  has_one :ingest, dependent: :destroy
  has_many :discussions

  delegate :concept_id, to: :recordable
  delegate :date_ingested, to: :ingest

  scope :all_records, ->(application_mode) {
    if Rails.configuration.mdq_enabled_feature_toggle
      application_mode == :mdq_mode ? where(daac: ApplicationHelper::MDQ_PROVIDERS).distinct : where(daac: ApplicationHelper::ARC_PROVIDERS).distinct
    else
      self.all
    end
  }
  scope :daac, ->(daac) { where(daac: daac) }
  scope :campaign, ->(campaign) { joins(:record_datas).where(record_data: { value: campaign }).distinct }
  scope :visible, -> { where.not(state: Record::STATE_HIDDEN) }
  scope :metadata_format, ->(format) { where(format: format) }

  after_update :update_associated_granule_state

  def update_associated_granule_state
    unless previous_changes['state'].nil?
      if collection? && has_associated_granule? && state != Record::STATE_HIDDEN.to_s
        granule_record = Record.find_by id: associated_granule_value
        granule_record.update(state: state)
      end
    end
  end

  REVIEW_ERRORS = {
    color_coding_complete?: "Not all columns have been flagged with a color, cannot close review.",
    has_enough_reviews?: "A review needs two completed reviews to be closed, cannot close review.",
    no_second_opinions?: "Some columns still need a second opinion review, cannot close review.  Please clear all second opinion flags.",
    updated_revision_if_needed?: "Some columns are still flagged red, cannot close review."
  }

  aasm column: 'state', whiny_persistence: false do
    state :open, initial: true
    state :in_arc_review, :ready_for_daac_review, :in_daac_review, :closed, :finished, :hidden

    event :start_arc_review do
      transitions from: :open, to: :in_arc_review
    end

    event :complete_arc_review do
      transitions from: :in_arc_review, to: :ready_for_daac_review, guards: [:color_coding_complete?, :has_enough_reviews?]
    end

    event :release_to_daac do
      transitions from: :ready_for_daac_review, to: :in_daac_review, guards: [:color_coding_complete?, :has_enough_reviews?, :no_second_opinions?], after: [:update_released_to_daac_date]
    end

    event :close do
      before do
        write_closed_date
      end

      transitions from: :in_daac_review, to: :closed, guards: [:updated_revision_if_needed?, :no_feedback_requested?]
    end

    event :revert do
      before do
        revert_closed_date unless read_attribute(:closed_date).nil?
      end
      transitions from: :in_daac_review, to: :ready_for_daac_review, after: [:remove_released_to_daac_date]
      transitions from: :closed, to: :in_daac_review
    end

    event :force_close do
      before do
        write_closed_date
      end

      transitions from: :in_daac_review, to: :closed
    end

    event :close_legacy_review do
      before do
        write_closed_date
      end

      transitions from: :open, to: :closed
    end

    event :finish do
      transitions from: :closed, to: :finished
    end

    event :allow_updates do
      transitions from: :finished, to: :closed
    end

    event :hide do
      transitions from: [:open, :in_arc_review, :ready_for_daac_review, :in_daac_review, :closed, :finished], to: :hidden
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
      unless comment_field.blank?
        value_keys.each do |value_field|
          # the regex here takes the comment key and checks if the value key is the same, but with 0-9 digits included.
          # if so, it adds the comment value to the fields.
          # so "Platforms/Platform/ShortName" value gets added to "Platforms/Platform0/ShortName"
          if value_field =~ /#{(comment_field.split('/').reduce("") {|sum, n| sum + '/' + n + '[0-9+]?'  })[1..-1]}/
            comment_hash[value_field] = comment_hash[comment_field]
          end
        end
      end
    end

    return comment_hash
  end

  def load_format_module
    if self.format == "dif10"
      self.extend(RecordFormats::Dif10Record)
    elsif self.format == "echo10" and self.recordable_type == 'Collection'
      self.extend(RecordFormats::Echo10Record)
    elsif self.format == 'echo10' and self.recordable_type == "Granule"
      self.extend(RecordFormats::Echo10Record)
    elsif self.format == "umm_json" and self.recordable_type == 'Collection'
      self.extend(RecordFormats::UmmRecord)
    elsif self.format == "umm_json" and self.recordable_type == 'Granule'
      self.extend(RecordFormats::UmmGRecord)
    else
      self.extend(RecordFormats::Echo10Record)
    end
  end

  def write_closed_date
    write_attribute(:closed_date, DateTime.now)
  end

  def revert_closed_date
    write_attribute(:closed_date, nil)
  end

  def has_associated_granule?
    associated_granule_value.present? && is_number?(associated_granule_value)
  end

  # ====Params
  # None
  # ====Returns
  # Boolean
  # ==== Method
  # Returns true if this record is an attribute of a Collection
  def collection?
    recordable_type == "Collection"
  end

  # ====Params
  # None
  # ====Returns
  # Boolean
  # ==== Method
  # Returns true if this record is an attribute of a Granule
  def granule?
    recordable_type == "Granule"
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

  def version
    data = record_datas.where(column_name: ['VersionId', 'Entry_ID/Version', 'Version']).first
    data.nil? ? 'n/a' : data.value
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
      data.value = "N/A" if data.value.blank?
      values_hash[data.column_name] = data.value
    end

    values_hash
  end

  def get_previous_revision
    # a set of records sorted by revision id in ascending order
    collection_records = self.recordable.get_records(false)
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

  def get_raw_data(format)
    collection? ? Cmr.get_raw_collection(concept_id, format) : Cmr.get_raw_granule_info(concept_id)['Granule']
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
    any_data_changed
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

  # ===Params
  # None
  # ===Returns
  # None
  # ===Method
  # Updates released_to_daac_date to the current time.
  # Intended to be called in an after block to the aasm transition
  def update_released_to_daac_date
    self.released_to_daac_date = Time.zone.now
  end

  def remove_released_to_daac_date
    self.released_to_daac_date = nil
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

    # Adding second opinions and feedback flags.
    opinion_values = get_opinions
    feedbacks = get_feedbacks

    bubble_set = bubble_set.map do |bubble|
      bubble[:opinion] = opinion_values[bubble[:field_name]]
      bubble[:feedback] = feedbacks[bubble[:field_name]]

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
    colors = self.get_colors

    colors.each do |key, value|
      if value == nil || !(value == "green" || value == "blue" || value == "yellow" || value == "red" || value == "gray")
        return false
      end
    end

    return true
  end

  def color?(code)
    return self.record_datas.where(color: code).count > 0
  end

  def completed_review_count
    return (self.reviews.select {|review| review.completed?}).count
  end

  def has_enough_reviews?
    return self.completed_review_count > 1
  end

  def no_second_opinions?
    return !(self.get_opinions.select {|key,value| value == true}).any?
  end

  def flagged_reviews?
    color_count("red") > 0
  end

  def updated_revision_if_needed?
    if flagged_reviews?
      cmr_revision_id = Cmr.current_revision_for(concept_id)
      review_revision_id = self.revision_id.to_i
      return false if (cmr_revision_id == -1)
      return cmr_revision_id > review_revision_id
    else
      return true
    end
  end

  def no_feedback_requested?
    (get_feedbacks.find { |key, value| value }).nil?
  end

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
    if format == 'umm_json' and recordable_type == "Collection"
      return mmt_sections
    end

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
    one_section = all_titles.select { |title| title.match(/^#{section_name}\//) }
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

  # Should return a list where each entry is a (title,[title_list])
  def mmt_sections
    section_list = []

    path = File.join(Rails.root,"/data/ummc_section_titles.json")
    json = JSON.load(File.read(path))
    field_list = []
    map = {}
    json.each do |obj|
      display_name = obj["displayName"]
      field_list << display_name
      map[display_name] = obj["properties"]
    end

    field_list.each do |title|
      section = self.get_mmt_section(title, map)
      if section[0][1].count > 0
        section_list += section
      end
    end

    used_titles = (section_list.map {|section| section[1]}).flatten
    all_titles = self.sorted_record_datas.map { |data| data.column_name }

    others = [["Other", all_titles.select {|title| !used_titles.include? title }]]

    section_list + others
  end

  def get_mmt_section(section_name, map)
    section_list = []

    all_titles = self.sorted_record_datas.map { |data| data.column_name }
    sections = map[section_name]
    sections.each do |sub_section_name|
      one_section = all_titles.select { |title| title.match(/^#{sub_section_name}/) }
      if one_section.any?
        # CMRARC-880: Check for mutiple matches and if they don't include "/", 
        # then just add the sub_section_name. This is because Version matches on 
        # both Version and VersionDescription and would add both, when it only
        # should add Version
        if one_section.length > 1 and !one_section.any? { |s| s.include?("/") } 
          section_list.push(sub_section_name)
        else 
          section_list.push(one_section)
        end
      end
    end
    [[section_name, section_list.flatten]]
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

      any_data_changed = true if update_feedbacks(feedback_values)

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

  def controlled_notice_list(element_list)
    {}.tap do |controlled_map|
      element_list.each do |element|
        controlled_map[element] = controlled_element_map[element] if controlled_element_map.key?(element)
      end
    end
  end

  def update_legacy_data(column_name, data, daac)
    record_data = record_datas.find_or_create_by(column_name: column_name, daac: daac)
    record_data.update_attributes(data) if record_data
  end

  def add_legacy_review(checked_by, comment, user = User.find_by(role: "admin"))
    final_comment = "This review was imported from legacy data\n"
    final_comment += "Checked By: #{checked_by}"
    final_comment += "Additional Comments: #{comment}" if comment
    review = reviews.create(user: user, report_comment: final_comment, review_state: 0)
    review.mark_complete
  end

  def add_long_name(long_name)
    record_data = record_datas.find_or_create_by(column_name: long_name_field, daac: daac)
    record_data.update_attributes(value: long_name)
  end

  def umm_json_link
    base_url = Cmr.get_cmr_base_url
    "#{base_url}/search/concepts/#{self.concept_id}/#{self.revision_id}.umm-json"
  end

  def native_link
    base_url = Cmr.get_cmr_base_url
    "#{base_url}/search/concepts/#{self.concept_id}/#{self.revision_id}.native"
  end

  def related_granule_record
    return nil if granule?

    granule = recordable.granules.first
    (granule.records.sort { |x,y| y.id.to_i <=> x.id.to_i }).first if granule
  end

  # returns the revision before this one.
  def prior_revision_record
    prior_record = nil

    records = self.recordable.get_records(false)

    records.each do |record|
      break if self.id == record.id
      prior_record = record
    end
    prior_record
  end

  # Helper method to return a map of all column names/record data objects for the specified record.
  # Returns column_name:record_data
  def get_column_record_data_map(record)
    record_data_map = {}
    record.record_datas.each do |data|
      record_data_map[data.column_name] = data
    end
    record_data_map
  end

  # Takes the recommendations from the prior record and copies them into the existing record.
  # Note: the recommendations include color,feedback, last_updated, opinion, recommendation field, discussions
  def copy_recommendations(prior_record)
    return 0, 0 if prior_record.nil?
    current = get_column_record_data_map(self)
    prior = get_column_record_data_map(prior_record)
    copied = 0
    not_copied = 0
    current.keys.each do |column_name|
      if prior[column_name].nil?
        not_copied += 1
        next
      end
      current_value = current[column_name].value
      prior_value = prior[column_name].value
      unless current_value.eql? prior_value
        not_copied += 1
        next
      end

      current_data = current[column_name]
      prior_data = prior[column_name]
      current_data.color = prior_data.color
      current_data.feedback = prior_data.feedback
      current_data.last_updated = prior_data.last_updated
      current_data.opinion = prior_data.opinion
      current_data.recommendation = prior_data.recommendation
      current_data.save
      copied += 1
    end
    copy_recommendations_date = Time.now.strftime("%m/%d/%Y at %I:%M%p")
    self.copy_recommendations_note = "Copied recommendations from revision #{prior_record.revision_id} on #{copy_recommendations_date}"
    save
    [copied, not_copied]
  end

end
