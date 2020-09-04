class CombineProviders < ActiveRecord::Migration[5.2]
  def up
    Record.all.visible.where(daac: ["LARC_ASDC", "LARC"]).find_each do |record|
      prior_daac = record.daac
      success = record.update(daac: "ASDC")
      if success
        Rails.logger.info "Successfully migrated provider to ASDC from #{prior_daac} #{record.recordable_type}"
      else
        Rails.logger.error "Could not migrate providers for ASDC from #{prior_daac} #{record.recordable_type}"
      end
    end
    Record.all.visible.where(daac: ["NSIDCV0", "NSIDC_ECS"]).find_each do |record|
      success = record.update(daac: "NSIDC")
      prior_daac = record.daac
      if success
        Rails.logger.info "Successfully migrated provider to NSIDC from #{prior_daac} #{record.recordable_type} "
      else
        Rails.logger.error "Could not migrate providers for NSIDC from #{prior_daac} #{record.recordable_type}"
      end
    end
    Record.all.visible.where(daac: ["GHRC_CLOUD", "LANCEAMSR2"]).find_each do |record|
      success = record.update(daac: "GHRC")
      prior_daac = record.daac
      if success
        Rails.logger.info "Successfully migrated provider to GHRC from #{prior_daac} #{record.recordable_type} "
      else
        Rails.logger.error "Could not migrate providers for GHRC from #{prior_daac} #{record.recordable_type}"
      end
    end
  end

  def down
    Record.all.visible.where(daac: ["ASDC", "NSIDC", "GHRC"]).find_each do |record|
      daac = record.concept_id.partition('-').last
      prior_daac = record.daac
      success = record.update(daac: daac)
      if success
        Rails.logger.info "Successfully rolled back provider to #{daac} from #{prior_daac} #{record.recordable_type}"
      else
        Rails.logger.error "Could not rollback provider for #{prior_daac} to #{daac} #{record.recordable_type}"
      end
    end
  end
end
