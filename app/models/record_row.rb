class RecordRow < ActiveRecord::Base
  belongs_to :recordable, :polymorphic => true
  belongs_to :user

  def update_values(values_hash)
    self.rawJSON = values_hash.to_json
    self.save
  end

  def values
    JSON.parse(self.rawJSON)
  end
end