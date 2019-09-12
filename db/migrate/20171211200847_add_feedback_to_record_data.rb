class AddFeedbackToRecordData < ActiveRecord::Migration[4.2]
  def change
    add_column :record_data, :feedback, :boolean, default: false
  end
end
