class UmmRequiredFields
  include Singleton

  def initialize
    csv_path = File.join(Rails.root, "/data/ummc_required_fields.csv")
    csv_list = CSV.read(csv_path)
    @required_fields = []
    csv_list.each do |n|
      @required_fields << n[0]
    end
  end

  def get_required_fields
    @required_fields
  end
end