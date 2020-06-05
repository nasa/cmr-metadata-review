class UnHideGranuleRecords < ActiveRecord::Migration[5.2]
  def change
    Record.where.not(state: Record::STATE_HIDDEN).find_each do |r|
      if r.collection? && r.has_associated_granule?
        granule_record = Record.find_by id: r.associated_granule_value
        if granule_record.nil?
          Rails.logger.error "Granule not found granule record id=#{r.associated_granule_value} for collection record id=#{r.id}"
        else
          if granule_record.state == Record::STATE_HIDDEN.to_s
            success = granule_record.update(state: r.state)
            if success
              Rails.logger.info "Successfully updated granule record id=#{r.associated_granule_value} for collection record id=#{r.id}"
            else
              Rails.logger.error "Could not update state of granule record id=#{r.associated_granule_value} for collection record id=#{r.id}"
            end
          end
        end
      end
    end
  end
end
