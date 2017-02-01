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
  COLLECTION_INFORMATION_FIELDS = ['ShortName', 'VersionId', 'InsertTime', 'LastUpdate', 'LongName', 'DatasetId', 'CollectionState',
                                   'Description', 'CollectionDataType', 'Orderable', 'Visible', 'RevisionDate', 'SuggestedUsage' ]


  def is_collection?
    self.recordable_type == "Collection"
  end

  def is_granule?
    self.recordable_type == "Granule"
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

  def section_bubble_data(field_set)
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


  def binary_script_values
    script_values = self.script_values
    # replaces the values in the hash with true/false depending on the script test helper
    binary_script_values = script_values.map { |key, val| [key, script_test(val)] }.to_h
    binary_script_values
  end



end