class UpdateGranuleStateFromCollection < ActiveRecord::Migration[5.2]
  def is_number?(object)
    true if Float(object) rescue false
  end

  def change
    collections_to_update = Record.where.not(associated_granule_value: nil)

    collections_to_update.each do |collection_record|
      if is_number? collection_record.associated_granule_value
        granule_record = Record.find_by id: collection_record.associated_granule_value
        unless granule_record.nil?
          granule_record.update(state: collection_record.state)
          Rails.logger.info "Migration UpdateGranuleStateFromCollection: Updating #{granule_record.concept_id}/#{granule_record.revision_id} state to #{granule_record.state}"
        end
      end
    end
  end
end
