#Record is the ActiveRecord representation of a record retrieved from the CMR
#An individual record can be identified by a unique concept-id and revision-id combination
#Record is a child of both Collection and Granule

class Record < ActiveRecord::Base
  include RecordHelper
  include Datable

  belongs_to :recordable, :polymorphic => true
  has_one :record_data, :as => :datable
  has_many :reviews
  has_many :script_comments
  has_one :ingest
  has_many :opinions
  has_many :recommendations
  has_many :colors
  has_many :flags
  has_many :discussions

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
  # Accesses the record's RecordData attribute and then returns the value of the "LongName" field
  def long_name 
    self.values["LongName"]
  end 

  # ====Params   
  # None
  # ====Returns
  # String
  # ==== Method
  # Accesses the record's RecordData attribute and then returns the value of the "ShortName" field
  def short_name
    self.values["ShortName"]
  end

  # ====Params   
  # None
  # ====Returns
  # String
  # ==== Method
  # Accesses the record's RecordData attribute and then returns the value of the "VersionId" field
  def version_id
    self.values["VersionId"]
  end


  # ====Params   
  # None
  # ====Returns
  # String
  # ==== Method
  # Lookes up the Ingest object related to this record, then returns the email of the user associated with the Ingest
  def ingested_by
    self.ingest.user.email
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
    if self.closed
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


  # ====Params   
  # None
  # ====Returns
  # Void
  # ==== Method
  # This method runs the automated script against a record and then saves the result in a new ScriptComment object      
  # The script is run through a shell command which accesses the python scripts in the /lib directory.       

  def evaluate_script(raw_data = nil)
      if raw_data.nil?
        raw_data = get_raw_data
      end
      #escaping json for passing to python
      collection_json = raw_data.to_json.gsub("\"", "\\\"")
      #running collection script in python
      #W option to silence warnings
      if self.is_collection?  
        script_results = `python -W ignore lib/CollectionChecker.py "#{collection_json}"  `
      else
        script_results = `python -W ignore lib/GranuleChecker.py "#{collection_json}"`
      end

      comment_hash = JSON.parse(script_results)
      comment_hash = Record.format_script_comments(comment_hash, self.values)
      comment_hash
  end

  def get_raw_data
    if is_collection?
      Cmr.get_raw_collection(concept_id)
    else
      Cmr.get_raw_granule(concept_id)
    end
  end

  def create_script(raw_data = nil)
      if raw_data.nil?
        raw_data = get_raw_data
      end
      comment_hash = self.evaluate_script(raw_data)
      score = score_script_hash(comment_hash)
      add_script_comment(comment_hash.to_json, score)
  end


  def self.format_script_comments(comment_hash, values_hash) 
    value_keys = values_hash.keys
    comment_keys = comment_hash.keys

    comment_keys.each do |comment_field|
      value_keys.each do |value_field|
        if value_field =~ /#{(comment_field.split('/').reduce("") {|sum, n| sum + '/' + n + '[0-9+]?'  })[1..-1]}/
          comment_hash[value_field] = comment_hash[comment_field]
        end
      end
    end

    return comment_hash
  end


  # ====Params   
  # None
  # ====Returns
  # Color object
  # ==== Method
  # This method looks up the record's associated Color objects.    
  # If any objects are found in the associated array, the first is returned.    
  # If none are found, then a new empty Color object is instantiated and returned.
  def get_colors
    colors = self.colors.first
    if colors.nil?
      colors = Color.new(record: self)
      colors.save
      colors.update_values(JSON.parse(self.blank_comment_JSON))
    end
    colors.reload
    colors
  end


  # ====Params   
  # None
  # ====Returns
  # ScriptComment object
  # ==== Method
  # This method looks up the record's associated ScriptComment objects.    
  # If any objects are found in the associated array, the first is returned.    
  # If none are found, then a new empty ScriptComment object is instantiated and returned.
  def get_script_comments
    script_comments = self.script_comments.first
    if script_comments.nil?
      self.create_script
      script_comments = self.script_comments.first
    end 
    script_comments.reload
    script_comments
  end


  # ====Params   
  # None
  # ====Returns
  # Flag object
  # ==== Method
  # This method looks up the record's associated Flag objects.    
  # If any objects are found in the associated array, the first is returned.    
  # If none are found, then a new empty Flag object is instantiated and returned.
  def get_flags
    flags = self.flags.first
    if flags.nil?
      flags = Flag.new(record: self)
      flags.save      
      flags.update_values(JSON.parse(self.blank_comment_JSON))
    end
    flags.reload
    flags
  end


  # ====Params   
  # None
  # ====Returns
  # Recommendation object
  # ==== Method
  # This method looks up the record's associated Recommendation objects.    
  # If any objects are found in the associated array, the first is returned.    
  # If none are found, then a new empty Recommendation object is instantiated and returned.
  def get_recommendations
    recommendations = self.recommendations.first
    if recommendations.nil?
      recommendations = Recommendation.new(record: self)
      recommendations.save
      recommendations.update_values(JSON.parse(self.blank_comment_JSON))
    end
    recommendations.reload
    recommendations
  end

  # ====Params   
  # None
  # ====Returns
  # Opinion object
  # ==== Method
  # This method looks up the record's associated Opinion objects.    
  # If any objects are found in the associated array, the first is returned.    
  # If none are found, then a new empty Opinion object is instantiated and returned.
  def get_opinions
    opinions = self.opinions.first
    if opinions.nil?
      opinions = Opinion.new(record: self)
      opinions.save
      new_opinion_hash = JSON.parse(self.blank_comment_JSON)
      new_opinion_hash = new_opinion_hash.map {|key, value| [key, false] }.to_h
      opinions.update_values(new_opinion_hash)
    end
    opinions.reload
    opinions
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


  # ====Params   
  # None
  # ====Returns
  # String, JSON
  # ==== Method
  # Returns a new JSON string based on the record's data.    
  # The record data is in the format of {"field1": "value1", "field2":"value2"}     
  # And the new returned JSON is in the format of {"field1": "", "field2":""}    
  # This provides a valueless hash to be filled in with data through the attribute classes (color, opinion, etc) 
  def blank_comment_JSON
    record_hash = self.values
    empty_hash = empty_contents(record_hash)
    empty_hash.to_json
  end


  # ====Params   
  # None
  # ====Returns
  # Hash
  # ==== Method
  # Accesses the record's automated script results and then returns the "field_name" => "value" pairs in a hash
  def script_values
    self.get_script_comments.values
  end

  # ====Params   
  # None
  # ====Returns
  # Integer
  # ==== Method
  # Returns the score originally generated in #score_script_hash method    
  # No further processing is done as this method accesses the score as a stored attribute
  def script_score
    self.get_script_comments.total_comment_count
  end



  def add_script_comment(script_JSON, score)
    new_comment = ScriptComment.new
    new_comment.record = self
    new_comment.total_comment_count = score
    if script_JSON.nil?
      new_comment.update_values(JSON.parse(self.blank_comment_JSON))
    else
      new_comment.update_values(JSON.parse(script_JSON))
    end
    new_comment.save!
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
    record_colors = self.get_colors.values
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
    opinion_values = self.get_opinions.values
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
    colors = self.get_colors.values

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
    return self.completed_review_count > 1
  end

  def no_second_opinions?
    return !(self.get_opinions.values.select {|key,value| value == true}).any?
  end

  def second_opinion_count
    opinion_values = self.get_opinions.values
    return opinion_values.values.reduce(0) {|sum, value| value == true ? (sum + 1): sum }
  end


  def close
    self.closed = true
    self.closed_date = DateTime.now
    self.save
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
    section_list = []
    
    contacts = self.get_section("Contacts/Contact")
    platforms = self.get_section("Platforms/Platform")
    campaigns = self.get_section("Campaigns/Campaign")
    temporal = self.get_section("Temporal")
    scienceKeywords = self.get_section("ScienceKeywords/ScienceKeyword")
    spatial = self.get_section("Spatial")
    online = self.get_section("OnlineResources/OnlineResource")
    accessURLs = self.get_section("OnlineAccessURLs")
    csdt = self.get_section("CSDTDescriptions")
    additional = self.get_section("AdditionalAttributes/AdditionalAttribute")

    section_list = section_list + contacts + platforms + campaigns + spatial + temporal + scienceKeywords + online + accessURLs + csdt + additional
    #finding the entries not in other sections
    used_titles = (section_list.map {|section| section[1]}).flatten
    all_titles = self.values.keys

    others = [["Collection Info", all_titles.select {|title| !used_titles.include? title }]]

    section_list = others + section_list
  end

  def get_section(section_name)
    section_list = []
    all_titles = self.values.keys
    one_section = all_titles.select {|title| title.match /#{section_name}\//}
    if one_section.any?
      return [[section_name, one_section]]
    else
      count = 0
      while (all_titles.select {|title| title.match /#{section_name}#{count.to_s}\//}).any?
        next_section = all_titles.select {|title| title.match /#{section_name}#{count.to_s}\//}
        section_list.push([section_name + count.to_s, next_section])
        count = count + 1
      end
      section_list
    end
  end

  def color_codes
    self.get_colors.values
  end


end