class GranuleRecord < ActiveRecord::Base
  include RecordHelper

  has_many :flags, as: :flagable
  has_one :ingest, as: :ingestable
  has_many :comments, as: :commentable
  has_many :reviews, as: :reviewable

  # has_many :users, through: :granule_reviews 


  def add_comment(user)
  #   create_table "collection_comments", force: :cascade do |t|
  #   t.integer "collection_record_id"
  #   t.integer "user_id"
  #   t.integer "total_comment_count"
  #   t.string  "rawJSON"
  # end
    new_comment = GranuleComment.new
    new_comment.granule_record = self
    new_comment.user = user
    new_comment.total_comment_count = 0
    new_comment.rawJSON = self.new_comment_JSON
    new_comment.save!
  end

  def add_script_comment(script_JSON)
    new_comment = GranuleComment.new
    new_comment.granule_record = self
    new_comment.user_id = -1
    new_comment.total_comment_count = 0
    new_comment.rawJSON = script_JSON
    new_comment.save!
  end

  def new_comment_JSON
    record_hash = JSON.parse(self.rawJSON)
    empty_hash = empty_contents(record_hash)
    empty_hash.to_json
  end

  def evaluate_script
    begin
      script_results = GranuleScript.run_script(self)
      self.add_script_comment(script_results)
    rescue
      return false
    end
    
    return true
  end

end
