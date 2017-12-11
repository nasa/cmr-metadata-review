class AddFeedbackToRecordData < ActiveRecord::Migration
  def change
    add_column :record_data, :feedback, :boolean, default: false
  end
end
