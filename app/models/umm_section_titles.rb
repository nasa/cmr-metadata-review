class UmmSectionTitles
  include Singleton

  def initialize
    csv_path = File.join(Rails.root, "/data/ummc_section_titles.csv")
    csv_list = CSV.read(csv_path)
    @section_titles = []
    csv_list.each do |n|
      @section_titles << n[0]
    end
  end

  def get_section_titles
    @section_titles
  end
end