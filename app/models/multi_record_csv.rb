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

  def to_csv(full_report)
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

          # Create collection column titles based on report user requests
          collection_column_titles = ['umm_json_link', 'short name', 'long name', 'concept_id', 'revision id']
          # Make sure the collection titles are only added once
          all_collection_titles_added = false
          records_for_format.each do |collection_record|
            data_hash = record_datas_organized_by_title(collection_record)
            collection_fields.each do |title|
              record_data = data_hash[title]
              if all_collection_titles_added == false 
                if full_report == true
                  collection_column_titles << title
                elsif !record_data.nil? && !full_report && (record_data.recommendation != "")
                  collection_column_titles << title
                end
              end
            end

            if full_report && all_collection_titles_added == false
              METRIC_FIELDS.each do |field|
                collection_column_titles.push(field)
              end
            end

            all_collection_titles_added = true

            csv << ['Collection'] + Array.new(collection_column_titles.count - 1) + ['Granule']
        
            record_line = generate_csv_line(collection_record, collection_column_titles, true, full_report)

            # Create granule column titles based on report user requests
            granule_column_titles = ['umm_json_link', 'long name', 'concept_id', 'revision id']
            associated_granule_value = collection_record.associated_granule_value
            if associated_granule_value.nil? || (associated_granule_value == 'Undefined')
              record_line += ['Associated Granule Undefined', 'N/A', 'N/A', 'N/A']
            else
              if associated_granule_value == 'No Granule Review'
                record_line += ['No Granule Review']
              else
                granule_record = Record.where(id: associated_granule_value).first
                granule_data_hash = record_datas_organized_by_title(granule_record)
                if !granule_record.nil?
                  granule_fields.each do |title|
                    granule_record_data = granule_data_hash[title]
                    if full_report == true
                      granule_column_titles << title
                    elsif granule_record_data && !full_report && (granule_record_data.recommendation != "")
                      granule_column_titles << title
                    end
                  end

                  if full_report
                    METRIC_FIELDS.each do |field|
                      granule_column_titles.push(field)
                    end
                  end
              
                  record_line += generate_csv_line(granule_record, granule_column_titles, false, full_report)
                end
              end
            end
            csv << collection_column_titles + granule_column_titles
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

  def record_datas_organized_by_title(record)
    {}.tap do |data_hash|
      record.record_datas.each do |record_data|
        data_hash[record_data.column_name] = record_data
      end
    end
  end

# need to take in another argument called full_report which is a boolean
  def generate_csv_line(record, fields, is_collection, full_report_boolean)
    line = if is_collection
      start_index = 4
      [record.umm_json_link] + [record.short_name] + [record.long_name] + [record.concept_id] + [record.revision_id]
    else
      start_index = 3
      [record.umm_json_link] + [record.long_name] + [record.concept_id] + [record.revision_id]
    end

    data_hash = record_datas_organized_by_title(record)
    
    fields.each_with_index do |title, index|
      data_string = nil
      record_data = data_hash[title]
      if full_report_boolean && !record_data.nil?
        data_string = "Color: #{record_data.color}\n"
        data_string += "Value: " + (record_data.value.blank? ? "n/a \n" : "#{record_data.value}\n")
        data_string += "Recommendation: #{record_data.recommendation}" unless record_data.recommendation.blank?
      elsif !full_report_boolean && !record_data.nil? && (record_data.recommendation != "")
        data_string = "Color: #{record_data.color}\n"
        data_string += "Value: " + (record_data.value.blank? ? "n/a \n" : "#{record_data.value}\n")
        data_string += "Recommendation: #{record_data.recommendation}"
      end
      
      if !data_string.nil?
        line << data_string
      elsif index > start_index and !title.include?(" fields")
        # Add nil entry to line up data properly for multi collection
        # Ignore for the initial record entries or the metric fields
        line << nil
      end
    end

    if full_report_boolean
      line + metric_data_array(record)
    else 
      line
    end
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
