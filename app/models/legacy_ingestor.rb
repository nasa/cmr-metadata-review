class LegacyIngestor

  attr_accessor :spreadsheet
  attr_accessor :granules

  COLLECTION_HEADER_ROW        = 5
  COLLECTION_COMMENTS_COLUMN   = 198
  COLLECTION_CHECKED_BY_COLUMN = 197
  GRANULE_HEADER_ROW           = 4
  GRANULE_CHECKED_BY_COLUMN    = 102
  GRANULE_COMMENTS_COLUMN      = 103
  
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

    data_sheet.rows[header_row+1..-1].each do |row|
      record = granules ? get_granule_record(row) : get_collection_record(row)
      next unless record

      row.to_a[1...checked_by_column].each_with_index do |review, index|
        column_name    = headers[index+1]
        data = {
          script_comment: review,
          color:          COLORS[row.format(index+1).pattern_fg_color]
        }

        record.update_legacy_data(column_name, data)
      end

      # Add additional comments as a review
      record.add_legacy_review(row[checked_by_column], row[comments_column])
    end
  end

  private

  def get_collection_record(row)
    url = parse_url(row[0])
    return unless url
    Collection.assemble_new_record_by_url(url)
  end

  def get_granule_record(row)
    concept_id = parse_concept_id(row[0])
    return unless concept_id
    Granule.add_granule_by_concept_id(concept_id)
  end

  def parse_url(data_set_id)
    return unless data_set_id
    data_set_id.match(/https:\/\/cmr\.earthdata\.nasa\.gov\/search\/concepts.*/)[0]
  end

  def parse_concept_id(granule_ur)
    return unless granule_ur
    granule_ur.match(/.*\((G\d+-.*)\).*/)[1]
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
end
