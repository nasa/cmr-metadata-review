class LegacyIngestor

  attr_accessor :spreadsheet
  attr_accessor :granules

  COLLECTION_HEADER_ROW = 5
  GRANULE_HEADER_ROW    = 4
  NOT_IN_METADATA       = "np"
  PROGRESS_BAR_FORMAT   = "%t: |%B| %p%"
  COMMENT_HEADER        = "Comments:"
  CHECKED_BY_HEADER     = "Checkedby:"
  
  # Translate from HEX to our colors in the DB
  COLORS = {
    "ffffff"   => "green",
    "FFFFFFFF" => "green",
    "FF4A86E8" => "blue",
    "FFFFFF00" => "yellow",
    "FFE06666" => "red"
  }

  def initialize(filename, granules = false)
    @spreadsheet = RubyXL::Parser.parse(filename)
    @granules    = granules
  end

  def ingest_records!
    data_sheet = spreadsheet[0]
    headers = data_sheet[header_row].cells.map(&:value)
    
    # Replaces any markings suchs as (a) or (b) in the data
    headers.each { |header| header.gsub!(/\([ab]\)/, "") }

    # Replace any spaces and asterisks in the headers to match CMR data
    headers.each { |header| header.gsub!(/[\s\*]/, "") }

    comment_by = headers.find_index(COMMENT_HEADER)
    checked_by = headers.find_index(CHECKED_BY_HEADER)

    data_rows = data_sheet[header_row+1..-1]
    data_rows = remove_nil_rows(data_rows)

    progress_bar = ProgressBar.create(total: data_rows.length, format: PROGRESS_BAR_FORMAT)

    data_rows.each do |row|
      begin
        if granules
          concept_id = parse_granule_concept_id(row.cells[0].value)
          record     = get_granule_record(concept_id)
        else
          url        = parse_url(row.cells[0].value)
          concept_id = Collection.parse_collection_url(url)[0] if url
          record     = get_collection_record(url)
        end

        next unless record

        row.cells[1...checked_by].each_with_index do |cell, index|
          column_name    = headers[index+1]
          data = {
            script_comment: cell.value,
            color:          COLORS[cell.fill_color]
          }

          add_field_errors(concept_id, column_name, cell.value) unless record.update_legacy_data(column_name, data)
        end
      

        # Add additional comments as a review
        record.add_legacy_review(row.cells[checked_by].value, row.cells[comment_by].value)

      rescue Cmr::CmrError => e
        errors << { concept_id: concept_id, reason: "There was an Error with the CMR: #{e.message}" }
      rescue Cmr::UnsupportedFormatError => e
        errors << { concept_id: concept_id, reason: "The record does not have a supported format: #{e.message}"}
      rescue ActiveRecord::RecordNotFound => e
        errors << { concept_id: concept_id, reason: e.message }
      rescue StandardError => e
        errors << { concept_id: concept_id, reason: "The legacy review could not be ingested: #{e.message}"}
      end

      progress_bar.increment
    end

    report_errors
    report_field_errors
  end

  private

  def get_collection_record(url)
    return unless url
    Collection.assemble_new_record_by_url(url)
  end

  def get_granule_record(concept_id)
    return unless concept_id
    Granule.add_granule_by_concept_id(concept_id)
  end

  def parse_url(data_set_id)
    return unless data_set_id
    data_set_id.match(/https:\/\/cmr\.earthdata\.nasa\.gov\/search\/concepts.*/)[0]
  end

  def parse_granule_concept_id(concept_id_data)
    return unless concept_id_data
    concept_id_data.match(/.*\((G\d+-.*)\).*/)[1]
  end

  def report_errors
    if errors.empty?
      puts "No errors when importing reviews"
    else
      errors.each do |error|
        puts "#{error[:concept_id]} review could not be ingested: #{error[:reason]}"
      end
    end
  end

  def add_field_errors(concept_id, column_name, review)
    return if review == NOT_IN_METADATA
    field_errors[concept_id] ||= {}
    field_errors[concept_id][column_name] = review
  end

  def report_field_errors
    if field_errors.empty?
      puts "No errors for specific columns when ingesting reviews"
    else
      field_errors.each do |concept_id, error_data|
        error_str = "The following fields were not ingested for #{concept_id}\n"
        error_data.each do |column_name, review|
          error_str += "\t#{column_name}: #{review}\n"
        end
        puts error_str
      end
    end
  end

  def remove_nil_rows(rows)
    rows.map do |row|
      row.cells.any? { |cell| cell.value.present? } ? row : nil
    end.compact!
  end

  def header_row
    @header_row ||= granules ? GRANULE_HEADER_ROW : COLLECTION_HEADER_ROW
  end

  def errors
    @errors ||= []
  end

  def field_errors
    @field_errors ||= {}
  end
end
