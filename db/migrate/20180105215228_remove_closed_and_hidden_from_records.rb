class RemoveClosedAndHiddenFromRecords < ActiveRecord::Migration[4.2]
  def up
    remove_column :records, :hidden
    remove_column :records, :closed
  end

  def down
    add_column :records, :hidden, :boolean, default: false
    add_column :records, :closed, :boolean, default: false

    Record.find_each do |r|
      if r.closed?
        r.closed = true
      elsif r.hidden?
        r.hidden = true
      end

      r.save!
    end
  end
end
