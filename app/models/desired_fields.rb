class DesiredFields < FormatFieldsMapping
  def get_csv_file(format)
    "/data/#{format}_desired_fields.csv"
  end
end