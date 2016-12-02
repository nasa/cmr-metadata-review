class CacheData
  BASE_URL = 'http://gcmdservices.gsfc.nasa.gov/static/kms'
  KEYWORDS = ['sciencekeywords', 'providers', 'projects', 'instruments',
              'platforms', 'locations', 'horizontalresolutionrange',
              'verticalresolutionrange', 'temporalresolutionrange',
              'rucontenttype', 'instruments']
  FILE_PATH = "#{Rails.root}/tmp/"

  class << self
    KEYWORDS.each do |keyword|
      define_method(keyword) do
        data = []
        path = "#{FILE_PATH}/#{keyword}.csv"
        return CSV.read(path) if File.exists?(path)
        store(keyword, path)
      end
    end

    def all
      KEYWORDS.each do |keyword|
        send(keyword)
      end
    end

    def store(keyword, path)
      data = []
      open("#{BASE_URL}/#{keyword}/#{keyword}.csv") do |f|
        data = CSV.parse(f)
        CSV.open(path, 'w') do |csv|
          data.each do |row|
            csv << row
          end
        end
      end
      data
    end
  end
end
