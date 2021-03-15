class ISOFieldMapping
  include Singleton

  def initialize
    @formats = %w(iso-mends iso-smap iso19115)
    @map = {}
    @formats.each do |format|
      csv_path = File.join(Rails.root, "/data/ummc_to_#{format}_mapping.csv")
      array = CSV.read(csv_path)
      m = {}
      array.map { |tuple| m[tuple[0]]=tuple[1] }
      @map[format] = m
    end
  end

  def mapping(format)
    @map[format]
  end
end