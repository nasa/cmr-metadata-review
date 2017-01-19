class Record < ActiveRecord::Base
  include RecordHelper
  belongs_to :recordable, :polymorphic => true
  has_many :reviews
  has_many :comments
  has_one :ingest
  has_many :flags

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
      collection_json = collection_data["Collection"].to_json.gsub("\"", "\\\"")
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

      add_script_comment(comment_hash.to_json)
    else
      #run granule script

    end

  end

  def blank_comment_JSON
    record_hash = JSON.parse(self.rawJSON)
    empty_hash = empty_contents(record_hash)
    empty_hash.to_json
  end

  def add_script_comment(script_JSON)
    add_comment(-1, script_JSON)
  end

  def add_comment(user_id, comment_json=nil)
    new_comment = Comment.new
    new_comment.record = self
    new_comment.user_id = user_id
    new_comment.total_comment_count = 0
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
  end

end