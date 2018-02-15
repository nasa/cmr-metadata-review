class LegacyIngestor

  attr_accessor :spreadsheet
  attr_accessor :granules

  COLLECTION_HEADER_ROW        = 5
  GRANULE_HEADER_ROW           = 4
  NOT_IN_METADATA              = "np"
  PROGRESS_BAR_FORMAT          = "%t: |%B| %p%"
  
  # Spreadsheet gem can't read colors exactly right
  COLORS = {
    brown:  "yellow",
    cyan:   "red",
    green:  "blue",
    white:  "green",
    border: "green"
  }

  def initialize(filename, granules = false)
    @spreadsheet = Spreadsheet.open(filename)
    @granules    = granules
  end

  def ingest_records!
    data_sheet = spreadsheet.worksheet(0)
    headers = data_sheet.row(header_row)
    
    # Replaces any markings suchs as (a) or (b) in the data
    headers.each { |header| header.gsub!(/\([ab]\)/, "") }

    # Replace any spaces and asterisks in the headers to match CMR data
    headers.each { |header| header.gsub!(/[\s\*]/, "") } 

    data_rows = data_sheet.rows[header_row+1..-1]
    data_rows = remove_nil_rows(data_rows)

    progress_bar = ProgressBar.create(total: data_rows.length, format: PROGRESS_BAR_FORMAT)

    data_rows.each do |row|
      begin
        
        if granules
          concept_id = parse_granule_concept_id(row[0])
          record     = get_granule_record(concept_id)
        else
          url        = parse_url(row[0])
          concept_id = Collection.parse_collection_url(url)[0] if url
          record     = get_collection_record(url)
        end

        next unless record

        row.to_a[1..-1].each_with_index do |review, index|
          column_name    = headers[index+1]
          data = {
            script_comment: review,
            color:          COLORS[row.format(index+1).pattern_fg_color]
          }

          add_field_errors(concept_id, column_name, review) unless record.update_legacy_data(column_name, data)
        end
      

        # Add additional comments as a review
        record.add_legacy_review

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
      row.any?(&:present?) ? row : nil
    end.compact!
  end

  def header_row
    @header_row ||= granules ? GRANULE_HEADER_ROW : COLLECTION_HEADER_ROW
  end

  def checked_by_column
    @checked_by_column ||= granules ? GRANULE_CHECKED_BY_COLUMN : COLLECTION_CHECKED_BY_COLUMN
  end

  def comments_column
    @comment_column ||= granules ? GRANULE_COMMENTS_COLUMN : COLLECTION_COMMENTS_COLUMN
  end

  def errors
    @errors ||= []
  end

  def field_errors
    @field_errors ||= {}
  end
end
