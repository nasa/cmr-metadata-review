class AddStateToRecords < ActiveRecord::Migration[4.2]

  def up
    add_column :records, :state, :string

    Record.find_each do |r|
      if r.hidden
        r.state = Record::STATE_HIDDEN
      elsif r.closed
        r.state = Record::STATE_CLOSED
      elsif r.reviews.count > 0 
        r.state = Record::STATE_IN_ARC_REVIEW
      else
        r.state = Record::STATE_OPEN
      end

      r.save!
    end
  end

  def down
    Record.find_each do |r|
      if r.hidden?
        r.hidden = true
      elsif r.closed? || r.in_daac_review?
        r.closed = true
        r.closed_date = DateTime.now
      else
        r.closed = false
        r.closed_date = nil
        
        r.hidden = false
      end

      r.save!

    end

    remove_column :records, :state
  end

end
