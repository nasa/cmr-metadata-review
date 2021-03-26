class SectionTitles
  include Singleton

  def initialize

    @formats = %w(ummc dif10 echo10 echo10_granule)
    @formats.each do |format|
      csv_path = File.join(Rails.root, "/data/#{format}_section_titles.csv")
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
      @ummc_section_titles = field_list
    when 'dif10'
      @dif10_section_titles = field_list
    when 'echo10'
      @echo10_section_titles = field_list
    when 'echo10_granule'
      @echo10_granule_section_titles = field_list
    end
  end

  def get_section_titles(format)
    case format
    when 'ummc'
      @ummc_section_titles
    when 'dif10'
      @dif10_section_titles
    when 'echo10'
      @echo10_section_titles
    when 'echo10_granule'
      @echo10_granule_section_titles
    else
      []
    end
  end
end