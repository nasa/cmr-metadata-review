class ControlledElements
  include Singleton

  def initialize
    @formats = ["umm_json"]
    @map = {}
    @formats.each do |format|
      csv_path = File.join(Rails.root, "/data/controlled_elements_#{format}.csv")
      array = CSV.read(csv_path)
      m = {}
      array.map { |tuple| m[tuple[0]]=tuple[1] }
      @map[format] = m
    end
  end

  def export_controlled_elements(format)
    map = {}
    if format == 'umm_json'
      map = ControlledElements.instance.map(format)
    end
    if format == 'dif10'
      map = RecordFormats::Dif10Fields::CONTROLLED_ELEMENT_MAP
    end
    if format == 'echo10'
      map = RecordFormats::Echo10Fields::CONTROLLED_ELEMENT_MAP
    end
    keys = map.keys.sort
    CSV.open("/tmp/#{format}.csv", "w") do |csv|
      csv << %w(field description)
      keys.each do |field|
        description = map[field]
        csv << [field, description]
      end
    end
  end

  def mapping(format)
    @map[format]
  end
end