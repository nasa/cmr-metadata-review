class LegacyIngestor

  attr_accessor :spreadsheet
  attr_accessor :granules

  COLLECTION_HEADER_ROW = 5
  GRANULE_HEADER_ROW    = 4
  # Spreadsheet gem can't read colors exactly right
  COLORS = {
    brown: "yellow",
    cyan:  "red",
    green: "blue",
    white: "green"
  }

  def initialize(filename, granules = false)
    @spreadsheet = Spreadsheet.open(filename)
    @granules = granules
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

      row.to_a[1..-1].each_with_index do |review, index|
        column_name    = headers[index+1]
        data = {
          script_comment: review,
          color:          COLORS[row.format(index+1).pattern_fg_color]
        }

        record.update_legacy_data(column_name, data)
      end
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
    data_set_id =~ /(https:\/\/cmr\.earthdata\.nasa\.gov\/search\/concepts.*)/
    $1
  end

  def parse_concept_id(granule_ur)
    granule_ur =~ /.*\((G\d+-.*)\).*/
    $1
  end

  def header_row
    @header_row ||= granules ? GRANULE_HEADER_ROW : COLLECTION_HEADER_ROW
  end
end
