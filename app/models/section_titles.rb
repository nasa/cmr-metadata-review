class SectionTitles < FormatFieldsMapping
  def get_csv_file(format)
    "/data/#{format}_section_titles.csv"
  end
end