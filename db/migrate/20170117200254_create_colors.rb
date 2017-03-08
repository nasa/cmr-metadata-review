class CreateColors < ActiveRecord::Migration
  def change
    create_table :colors do |t|
      t.belongs_to :record, index: true
      t.integer    :total_flag_count
    end
  end
end
