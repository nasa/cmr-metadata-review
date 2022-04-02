class IncludeFormatInEcho10GranuleRecords < ActiveRecord::Migration[6.0]
  def up
    Record.where(recordable_type: 'Granule').find_each do |record|
      if record.format.blank?
        success = record.update(format: 'echo10')
        if success
          Rails.logger.info "Successfully migrated granule record format to include echo10"
        else
          Rails.logger.error "Could not migrate granule record format to include echo10"
        end
      end
    end

    Record.where(recordable_type: 'Granule').find_each do |record|
      if record.native_format.blank?
        success = record.update(native_format: record.format)
        if success
          Rails.logger.info "Successfully migrated granule record native_format to include echo10"
        else
          Rails.logger.error "Could not migrate granule record native_format to include echo10"
        end
      end
    end

  end
end
