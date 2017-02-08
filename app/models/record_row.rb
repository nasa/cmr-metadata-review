class RecordRow < ActiveRecord::Base
  belongs_to :recordable, :polymorphic => true
  belongs_to :user

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


  def update_opinion_values(opinion_values)
    opinion = RecordRow.where(record_id: self.id, row_name: "second_opinion").first
    opinion.rawJSON = opinion_values.to_json
    opinion.save
  end

  def update_values(values_hash)
    self.rawJSON = values_hash.to_json
    self.save
  end

  def values
    JSON.parse(self.rawJSON)
  end
end