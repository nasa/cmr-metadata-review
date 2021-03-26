class RequiredFields
  include Singleton

  def initialize
    @formats = %w(ummc dif10 echo10 echo10_granule)
    @formats.each do |format|
      csv_path = File.join(Rails.root, "/data/#{format}_required_fields.csv")
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
      @ummc_required_fields = field_list
    when 'dif10'
      @dif10_required_fields = field_list
    when 'echo10'
      @echo10_required_fields = field_list
    when 'echo10_granule'
      @echo10_granule_required_fields = field_list
    end
  end

  def get_required_fields(format)
    case format
    when 'ummc'
      @ummc_required_fields
    when 'dif10'
      @dif10_required_fields
    when 'echo10'
      @echo10_required_fields
    when 'echo10_granule'
      @echo10_granule_required_fields
    else
      []
    end
  end
end