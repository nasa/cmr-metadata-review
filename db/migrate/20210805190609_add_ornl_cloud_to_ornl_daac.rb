class AddOrnlCloudToOrnlDaac < ActiveRecord::Migration[6.0]
  def up
    Record.where(daac: ApplicationHelper.providers("ORNL_DAAC")).find_each do |record|
      prior_daac = record.daac
      success = record.update(daac: "ORNL_DAAC")
      if success
        Rails.logger.info "Successfully migrated provider to #{record.daac} from #{prior_daac}"
      else
        Rails.logger.error "Could not migrate providers for ORNL_DAAC to #{record.daac} from #{prior_daac}"
      end
    end
  end

  def down
    Record.where(daac: ApplicationHelper.providers("ORNL_DAAC")).find_each do |record|
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
