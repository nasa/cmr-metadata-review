class LegacyIngestor

  attr_accessor :spreadsheet

  HEADER_ROW = 5
  
  # Spreadsheet gem can't read colors exactly right
  COLORS = {
    brown: "yellow",
    cyan:  "red",
    green: "blue",
    white: "green"
  }

  def initialize(filename)
    @spreadsheet = Spreadsheet.open(filename)
  end

  def ingest_records!
    data_sheet = spreadsheet.worksheet(0)
    headers = data_sheet.row(HEADER_ROW)
    # Replace any spaces and asterisks in the headers to match CMR data
    headers.each { |header| header.gsub!(/[\s\*]/, "") }
    
    data_sheet.rows[HEADER_ROW+1..-1].each do |row|
      url = parse_url(row[0])
      next unless url
      collection_record = Collection.assemble_new_record_by_url(url)

      row.to_a[1..-1].each_with_index do |review, index|
        column_name    = headers[index+1]
        data = {
          script_comment: review,
          color:          COLORS[row.format(index+1).pattern_fg_color]
        }

        collection_record.update_legacy_data(column_name, data)
      end
    end
  end

  def parse_url(data_set_id)
    data_set_id =~ /(https:\/\/cmr\.earthdata\.nasa\.gov\/search\/concepts.*)/
    $1
  end
end
