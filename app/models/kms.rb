require 'open-uri'
require 'csv'

class Kms
  include ApplicationHelper
  # KeywordChecker
  # init
  # For each scheme
  # download csv of all keywords in that scheme
  # For each keyword that scheme
  # add keyword to our keyword_path list
  # get_invalid_keywords(collection):
  #     invalid_keyword_paths = []
  # for ummc_field in collection //  Science Keywords, Platforms, Instruments, Projects, Data Centers, Data Format, Processing Level
  # keyword_paths = get_all_keyword_paths(umms_field)
  # for keyword_path in kewywords_path
  #   if keyword_path is invalid
  #     invalid_keyword_paths << keyword_path
  #   end
  # end
  # end
  # return invalid_keyword_paths

  def initialize
    @keyword_paths_dict = {}
  end

  def download_kms_keywords(schemes)
    schemes.each do |scheme|
      csv_array = download_keywords(scheme)
      keyword_paths = create_keyword_paths(scheme, csv_array)
      save_keywords(scheme, keyword_paths)
    end
  end

  def save_keywords(scheme, keyword_paths)
    @keyword_paths_dict[scheme] = keyword_paths
  end

  def create_keyword_paths(scheme, csv_array)
    result = []
    i = get_keyword_index(scheme)
    csv_array.each do |n|
      path = ''
      if scheme == 'sciencekeywords'
        for j in 0..i
          if !n[j].blank?
            path = path + n[j].gsub("\"", '').strip
            path = path + '|'
          end
        end
        result << path.chop unless path.blank?
      else
        path = n[i]
        result << path.gsub("\"", '').strip unless path.blank?
      end
    end
    return result
  end

  def download_keywords(scheme)
    keywords = []
    url = get_kms_url(scheme)
    file_path = "/tmp/#{scheme}.csv"
    File.write(file_path, open(url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read)
    CSV.foreach(file_path, liberal_parsing: true) do |row|
      keywords << row
    end
    return keywords[2..keywords.length]
  end

  def get_keyword_paths(scheme)
    return @keyword_paths_dict[scheme]
  end

  def get_keyword_index(scheme)
    if scheme == 'sciencekeywords'
      return 6
    elsif scheme == 'platforms'
      return 2
    elsif scheme == 'instruments'
      return 4
    elsif scheme == 'projects'
      return 1
    elsif scheme == 'providers'
      return 4
    elsif scheme == 'GranuleDataFormat'
      return 0
    elsif scheme == 'ProductLevelId'
      return 0
    end
    return -1
  end

  def get_kms_base_url
    kms_base_url = Rails.application.config.kms_base_url
    if kms_base_url.nil?
      kms_base_url = 'https://gcmd.earthdata.nasa.gov'
    end
    kms_base_url
  end

  def get_kms_url(scheme)
    return get_kms_base_url() + "/kms/concepts/concept_scheme/#{scheme}?format=csv"
  end

end