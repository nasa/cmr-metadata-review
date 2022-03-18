class FormatFieldsMapping
  include Singleton
  def initialize
    @format_fields_dict = {}
    @formats = %w(ummc ummg dif10 echo10 echo10_granule)
    @formats.each do |format|
      csv_path = File.join(Rails.root, get_csv_file(format))
      csv_list = CSV.read(csv_path)
      field_list = []
      csv_list.each do |n|
        field_list << n[0]
      end
      @format_fields_dict[format] = field_list
    end
  end
  def get_format_fields(format)
    @format_fields_dict[format]
  end
end
