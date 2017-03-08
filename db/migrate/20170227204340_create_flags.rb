class CreateFlags < ActiveRecord::Migration
  def change
    create_table :flags do |t|
      t.belongs_to :record, index: true
      t.integer    :total_flag_count
    end
  end
end
