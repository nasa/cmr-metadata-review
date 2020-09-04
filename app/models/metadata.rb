class Metadata < ApplicationRecord
  self.abstract_class = true

  scope :all_metadata, ->(application_mode) {
    if Rails.configuration.mdq_enabled_feature_toggle
      provider_list = application_mode == :mdq_mode ? ApplicationHelper::MDQ_PROVIDERS : ApplicationHelper::ARC_PROVIDERS
      records = Record.where({daac: provider_list}).distinct
      self.joins(:records).merge(records)
    else
      self.all
    end
  }

  def get_records(descending = true)
    visible_records = records.visible
    sorted_records = visible_records.sort_by { |record| record.revision_id.to_i }
    sorted_records.reverse! if descending
    sorted_records
  end

  def self.daac_from_concept_id(concept_id)
    daac = concept_id.partition('-').last
    daac = 'ASDC'  if daac == 'LARC_ASDC' || daac == 'LARC'
    daac = 'NSIDC' if daac == 'NSIDCV0' || daac == 'NSIDC_ECS'
    daac = 'GHRC'  if daac == 'GHRC_CLOUD' || daac == 'LANCEAMSR2'
    daac
  end
end