class MultiRecordCsv

  attr_reader :collections
  attr_reader :granules

  IDENTIFIER_COLUMN = "DataSetId (ShortName) - umm-json link"
  GRANULE_IDENTIFIER_COLUMN = "Collection Name (Concept Id) - Granule UR"

  METRIC_FIELDS     = [
    "# Red fields (absolute errors):",
    "# Yellow fields (recommended fixes)",
    "# Blue fields (observations/ may or may not need to be fixed)",
    "# np fields (not in the metadata, and not marked by any color)",
    "# fields checked",
    "% red fields",
    "% yellow fields",
    "% blue fields"
  ]
  FORMATS = Collection::SUPPORTED_FORMATS

  def initialize(records)
    @collections = records.where(recordable_type: "Collection")
    @granules    = records.where(recordable_type: "Granule")
  end

  def to_csv
    CSV.generate do |csv|
      csv << ["CMR Multiple Record Report"]
      csv << ["Collections"]

      # Collections
      FORMATS.each do |metadata_format|
        records_for_format = collections.metadata_format(metadata_format)
        next if records_for_format.empty?

        fields = determine_fields(records_for_format)

        csv << [metadata_format]
        csv << csv_titles(fields)

        records_for_format.each do |record|
          csv << generate_csv_line(record, fields)
        end

        csv << []
      end

      # Granules
      csv << ["Granules"]

      fields = determine_fields(granules)

      csv << csv_titles(fields)
      granules.each do |record|
        csv << generate_csv_line(record, fields)
      end
    end
  end

  private

  def determine_fields(records)
    RecordData.where(record: records).pluck(:column_name).uniq.sort
  end

  def csv_titles(fields)
    [IDENTIFIER_COLUMN] + fields + METRIC_FIELDS
  end

  def record_datas_organized_by_title(record)
    {}.tap do |data_hash|
      record.record_datas.each do |record_data|
        data_hash[record_data.column_name] = record_data
      end
    end
  end

  def generate_csv_line(record, fields)
    line      = [title_column(record)]
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
    red_fields_count    = record.record_datas.where(color: "red").count
    yellow_fields_count = record.record_datas.where(color: "yellow").count
    blue_fields_count   = record.record_datas.where(color: "blue").count
    np_count            = record.record_datas.where(script_comment: "np").count
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

  def title_column(record)
    if record.collection?
      "#{record.long_name} (#{record.short_name}) - #{record.umm_json_link}"
    else
      "#{record.recordable.collection_name} (#{record.concept_id}) - #{record.long_name}"
    end
  end
end
