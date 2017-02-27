class RecordData < ActiveRecord::Base
  belongs_to :datable, :polymorphic => true

end