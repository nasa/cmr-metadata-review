class Record < ActiveRecord::Base
  belongs_to :recordable, :polymorphic => true
end