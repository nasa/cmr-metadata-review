class DesiredFields
  include Singleton

  def initialize
    @formats = %w(ummc dif10 echo10 echo10_granule)
    @formats.each do |format|
      csv_path = File.join(Rails.root, "/data/#{format}_desired_fields.csv")
      csv_list = CSV.read(csv_path)
      field_list = []
      csv_list.each do |n|
        field_list << n[0]
      end
      assign_field_list(field_list, format)
    end
  end

  def assign_field_list(field_list, format)
    case format
    when 'ummc'
      @ummc_desired_fields = field_list
    when 'dif10'
      @dif10_desired_fields = field_list
    when 'echo10'
      @echo10_desired_fields = field_list
    when 'echo10_granule'
      @echo10_granule_desired_fields = field_list
    end
  end

  def get_desired_fields(format)
    case format
    when 'ummc'
      @ummc_desired_fields
    when 'dif10'
      @dif10_desired_fields
    when 'echo10'
      @echo10_desired_fields
    when 'echo10_granule'
      @echo10_granule_desired_fields
    else
      []
    end
  end
end