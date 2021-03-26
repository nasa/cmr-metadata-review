class DesiredFields
  include Singleton

  def initialize
    @format_fields_dict = {}
    @formats = %w(ummc dif10 echo10 echo10_granule)
    @formats.each do |format|
      csv_path = File.join(Rails.root, "/data/#{format}_desired_fields.csv")
      csv_list = CSV.read(csv_path)
      field_list = []
      csv_list.each do |n|
        field_list << n[0]
      end
      @format_fields_dict[format] = field_list
    end
  end

  def get_desired_fields(format)
    @format_fields_dict[format]
  end
end