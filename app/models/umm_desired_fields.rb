class UmmDesiredFields
  include Singleton

  def initialize
    csv_path = File.join(Rails.root, "/data/ummc_desired_fields.csv")
    csv_list = CSV.read(csv_path)
    @desired_fields = []
    csv_list.each do |n|
      @desired_fields << n[0]
    end
  end

  def get_desired_fields
    @desired_fields
  end
end