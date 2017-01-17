class CreateFlags < ActiveRecord::Migration
  def change
    create_table :flags do |t|
      t.belongs_to :record, index: true
      t.belongs_to :user, index: true
      t.integer    :total_flag_count
      t.string     :rawJSON
    end
  end
end
