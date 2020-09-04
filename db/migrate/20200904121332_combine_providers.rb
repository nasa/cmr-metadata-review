class CombineProviders < ActiveRecord::Migration[5.2]
  def up
    Record.where(daac: ["LARC_ASDC", "LARC"]).find_each do |record|
      success = record.update(daac: "ASDC")
      if success
        Rails.logger.info "Successfully combined providers for ASDC"
      else
        Rails.logger.error "Could not combine providers for ASDC"
      end
    end
    Record.where(daac: ["NSIDCV0", "NSIDC_ECS"]).find_each do |record|
      success = record.update(daac: "NSIDC")
      if success
        Rails.logger.info "Successfully combined providers for NSIDC"
      else
        Rails.logger.error "Could not combine providers for NSIDC"
      end
    end
    Record.where(daac: ["GHRC_CLOUD", "LANCEAMSR2"]).find_each do |record|
      success = record.update(daac: "GHRC")
      if success
        Rails.logger.info "Successfully combined providers for GHRC"
      else
        Rails.logger.error "Could not combine providers for GHRC"
      end
    end
  end
  def down

  end
end
