class Record < ActiveRecord::Base
  include RecordHelper
  belongs_to :recordable, :polymorphic => true
  has_many :reviews
  has_many :comments
  has_one :ingest
  has_many :flags

  COLLECTION_SECTIONS = ["COLLECTION INFORMATION", "SPATIAL INFORMATION", "DATA IDENTIFICATION", "DATA CENTERS", "DISTRIBUTION INFORMATION", 
                         "DATA CONTACTS", "DESCRIPTIVE KEYWORDS", "COLLECTION CITATIONS", "ACQUISITION INFORMATION", "METADATA INFORMATION",
                         "TEMPORAL INFORMATION"]
  COLLECTION_FIELDS = [['ShortName', 'VersionId', 'InsertTime', 'LastUpdate', 'LongName', 'DatasetId', 'CollectionState',
                                   'Description', 'CollectionDataType', 'Orderable', 'Visible', 'RevisionDate', 'SuggestedUsage' ]]


  def is_collection?
    self.recordable_type == "Collection"
  end

  def is_granule?
    self.recordable_type == "Granule"
  end

  def long_name 
    JSON.parse(self.rawJSON)["LongName"]
  end 

  def short_name
    JSON.parse(self.rawJSON)["ShortName"]
  end


  def evaluate_script
    collection_data = JSON.parse(rawJSON)
    comment_JSON = blank_comment_JSON
    comment_hash = JSON.parse(comment_JSON)

    if self.is_collection?
      #escaping json for passing to python
      collection_json = collection_data.to_json.gsub("\"", "\\\"")
      #running collection script in python
      script_results = `python lib/CollectionChecker.py "#{collection_json}"`

      #parsing the prints from the script into sections
      script_results = script_results.split("\n")

      #removing any of the script results that have no text, ie ", " or ",  "
      script_results[1] = script_results[1].split(",").select { |entry| (!(entry =~ /[a-zA-Z0-9]/).nil?) }

      #splitting the row headers into a list
      script_results[3] = (script_results[3].split(",").select { |entry| (!(entry =~ /[a-zA-Z0-9]/).nil?) }).map { |entry| entry.gsub(/\s+/, "") }

      #creating a hash with values { row_header => result_string }
      comment_hash = Hash[script_results[3].zip(script_results[1])]


      score = score_script_hash(comment_hash)

      add_script_comment(comment_hash.to_json, score)
    else
      #run granule script

    end

  end

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

  def blank_comment_JSON
    record_hash = JSON.parse(self.rawJSON)
    empty_hash = empty_contents(record_hash)
    empty_hash.to_json
  end

  def script_values
    script_comment = self.comments.where(user_id: -1).first
    if script_comment.nil?
      nil
    else 
      JSON.parse(script_comment.rawJSON)
    end
  end

  def script_score
    script_comment = self.comments.where(user_id: -1).first
    if script_comment.nil?
      0
    else 
      script_comment.total_comment_count
    end
        
  end

  def add_script_comment(script_JSON, score)
    add_comment(-1, script_JSON, score)
  end

  def add_comment(user_id, comment_json=nil, score=0)
    new_comment = Comment.new
    new_comment.record = self
    new_comment.user_id = user_id
    new_comment.total_comment_count = score
    if comment_json.nil?
      new_comment.rawJSON = self.blank_comment_JSON
    else
      new_comment.rawJSON = comment_json
    end
    new_comment.save!
  end

  def add_flag(user_id, flag_json=nil)
    new_flag = Flag.new
    new_flag.record = self
    new_flag.user_id = user_id
    new_flag.total_flag_count = 0
    if flag_json.nil?
      new_flag.rawJSON = self.blank_comment_JSON
    else
      new_flag.rawJSON = comment_json
    end
    new_flag.save!
  end

  def add_review(user_id)
    new_review = Review.new
    new_review.record = self
    new_review.user_id = user_id
    new_review.review_state = 0
    new_review.save!
  end

  def section_bubble_data(field_set_index)
    field_set = Record.get_collection_section_list(field_set_index)
    record_set = JSON.parse(self.rawJSON)
    included_field_set = field_set.select { |field| !(record_set[field].nil?) }
    bubble_set = []

    # setting flag data
    record_flags = self.flags
    if record_flags.empty?
      bubble_set = included_field_set.map { |field| {"field_name": field, "color": "white"} }
    else
      flagset = JSON.parse(record_flags.first.rawJSON)
      bubble_set = included_field_set.map do |field| 
        if flagset[field] == ""
          bubble_color = "white"
        else
          bubble_color = flagset[field]
        end

        { "field_name": field, "color": bubble_color } 
      end
    end

    # adding the automated script results to each bubble
    binary_script_values = self.binary_script_values
    if binary_script_values.empty?
      bubble_set = bubble_set.map { |bubble| bubble[:script] = true }
    else
      bubble_set = bubble_set.map do |bubble| 
        bubble[:script] = binary_script_values[bubble[:field_name]]
        bubble
      end 
    end

    bubble_set
  end


  def color_coding_complete
    colors = JSON.parse(self.flags.first.rawJSON)

    colors.each do |key, value|
      if value == nil || value == ""
        return false
      end
    end

    return true
  end

  def close
    self.closed = true
    self.save
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


  def self.get_collection_section_list(list_index) 
    return COLLECTION_FIELDS[list_index]
  end

  def section_titles(section_index) 
    section_list = Record.get_collection_section_list(section_index.to_i)
    record_set = JSON.parse(self.rawJSON)
    included_field_set = section_list.select { |field| !(record_set[field].nil?) }
    included_field_set
  end

  def values 
    JSON.parse(self.rawJSON)
  end

  def color_codes
    flags = self.flags
    if flags.empty?
      self.add_flag(-1)
      JSON.parse(self.flags.first.rawJSON)
    else
      JSON.parse(self.flags.first.rawJSON)
    end
  end

  def update_color_codes(color_code_values)
    color_codes = self.flags.first
    color_codes.rawJSON = color_code_values.to_json
    color_codes.save
  end

  def flag_values
    flag = RecordRow.where(record_id: self.id, row_name: "flag")
    if flag.empty?
      flag = RecordRow.new(record_id: self.id, row_name: "flag", rawJSON: self.blank_comment_JSON)
      flag.save
    else
      flag = flag.first
    end

    JSON.parse(flag.rawJSON)
  end

  def update_flag_values(flag_hash)
    flag_object = RecordRow.where(record_id: self.id, row_name: "flag")
    if flag_object.empty?
      flag_object = RecordRow.new(record_id: self.id, row_name: "flag", rawJSON: self.blank_comment_JSON)
      flag_object.save
    else
      flag_object = flag_object.first
    end
    flag_object.rawJSON = flag_hash.to_json
    flag_object.save
  end

  def recommendation_values
    recommendation = RecordRow.where(record_id: self.id, row_name: "recommendation")
    if recommendation.empty?
      recommendation = RecordRow.new(record_id: self.id, row_name: "recommendation", rawJSON: self.blank_comment_JSON)
      recommendation.save
    else
      recommendation = recommendation.first
    end

    JSON.parse(recommendation.rawJSON)
  end

  def update_recommendation(value_hash)
    recommendation = RecordRow.where(record_id: self.id, row_name: "recommendation").first
    recommendation.rawJSON = value_hash.to_json
    recommendation.save
  end

  def second_opinion_values
    second_opinion = RecordRow.where(record_id: self.id, row_name: "second_opinion")
    if second_opinion.empty?
      second_opinion = RecordRow.new(record_id: self.id, row_name: "second_opinion", rawJSON: self.blank_comment_JSON)
      second_opinion.save
    else
      second_opinion = second_opinion.first
    end

    JSON.parse(second_opinion.rawJSON)
  end

  def update_opinion_values(opinion_values)
    opinion = RecordRow.where(record_id: self.id, row_name: "second_opinion").first
    opinion.rawJSON = opinion_values.to_json
    opinion.save
  end

end