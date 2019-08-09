# frozen_string_literal: true

class MultiRecordCsv
  attr_reader :collections

  METRIC_FIELDS = [
    '# Red fields (absolute errors):',
    '# Yellow fields (recommended fixes)',
    '# Blue fields (observations/ may or may not need to be fixed)',
    '# np fields (not in the metadata, and not marked by any color)',
    '# fields checked',
    '% red fields',
    '% yellow fields',
    '% blue fields'
  ].freeze
  FORMATS = Collection::SUPPORTED_FORMATS

  def initialize(records)
    @collections = records.where(recordable_type: 'Collection')
  end

  def to_csv
    CSV.generate do |csv|
      csv << ['CMR Multiple Record Report']

      if collections.any?
        # Collections
        FORMATS.each do |metadata_format|
          records_for_format = collections.metadata_format(metadata_format)
          next if records_for_format.empty?

          granules = []
          # Get a list of all granules
          records_for_format.each do |record|
            associated_granule_value = record.associated_granule_value
            if associated_granule_value.blank?        ||
              associated_granule_value == 'Undefined' ||
              associated_granule_value == 'No Granule Review'
              next
            end
            granules << Record.where(id: associated_granule_value).first
          end

          # Determine all possible fields for granules, note only echo10 granules are reviewed, so at this
          # point no need to group by format.   we may need to group by format in the future once umm-g
          # is supported.
          granule_fields = determine_fields(granules)
          collection_fields = determine_fields(records_for_format)
          csv << [metadata_format]
          csv << ['Collection'] + Array.new(csv_titles(collection_fields, true).count - 1) + ['Granule']
          csv << csv_titles(collection_fields, true) + csv_titles(granule_fields, false)

          records_for_format.each do |collection_record|
            record_line = generate_csv_line(collection_record, collection_fields, true)
            associated_granule_value = collection_record.associated_granule_value
            if associated_granule_value.nil? || (associated_granule_value == 'Undefined')
              record_line += ['Associated Granule Undefined']
            else
              if associated_granule_value == 'No Granule Review'
                record_line += ['No Granule Review']
              else
                granule_record = Record.where(id: associated_granule_value).first
                record_line += generate_csv_line(granule_record, granule_fields, false)
              end
            end
            csv << record_line
          end

          csv << []
        end
      end
    end
  end

  private

  def determine_fields(records)
    RecordData.where(record: records).pluck(:column_name).uniq.sort
  end

  def csv_titles(fields, is_collection)
    if is_collection
      ['umm_json_link', 'short name', 'long name', 'concept_id', 'revision id'] + fields + METRIC_FIELDS
    else
      ['umm_json_link', 'granule ur', 'concept_id', 'revision id'] + fields + METRIC_FIELDS
    end
  end

  def record_datas_organized_by_title(record)
    {}.tap do |data_hash|
      record.record_datas.each do |record_data|
        data_hash[record_data.column_name] = record_data
      end
    end
  end

  def generate_csv_line(record, fields, is_collection)
    line = if is_collection
             [record.umm_json_link] + [record.short_name] + [record.long_name] + [record.concept_id] + [record.revision_id]
           else
             [record.umm_json_link] + [record.long_name] + [record.concept_id] + [record.revision_id]
           end

    data_hash = record_datas_organized_by_title(record)

    fields.each do |title|
      data_string = nil
      if record_data = data_hash[title]
        data_string = "Color: #{record_data.color}\n"
        data_string += "Script Comment: #{record_data.script_comment}\n" unless record_data.script_comment.blank?
        data_string += "Recommendation: #{record_data.recommendation}" unless record_data.recommendation.blank?
      end

      line << data_string
    end

    line + metric_data_array(record)
  end

  def metric_data_array(record)
    red_fields_count    = record.record_datas.where(color: 'red').count
    yellow_fields_count = record.record_datas.where(color: 'yellow').count
    blue_fields_count   = record.record_datas.where(color: 'blue').count
    np_count            = record.record_datas.where(script_comment: 'np').count
    total_fields        = record.record_datas.count
    red_percent         = (red_fields_count.to_f / total_fields.to_f).round(4) * 100
    yellow_percent      = (yellow_fields_count.to_f / total_fields.to_f).round(4) * 100
    blue_percent        = (blue_fields_count.to_f / total_fields.to_f).round(4) * 100

    [
      red_fields_count,
      yellow_fields_count,
      blue_fields_count,
      np_count,
      total_fields,
      red_percent,
      yellow_percent,
      blue_percent
    ]
  end
end
