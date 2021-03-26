class RequiredFields < FormatFieldsMapping
  def get_csv_file(format)
    "/data/#{format}_required_fields.csv"
  end
end