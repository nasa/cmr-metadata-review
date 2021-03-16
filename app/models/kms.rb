require 'open-uri'
require 'csv'
require 'json'
require 'openssl'

class Kms
  include ApplicationHelper
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

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

  def get_recommended_keywords(invalid_keywords, scheme)
    begin
      url = get_recommended_keywords_url(scheme)
      payload = {}
      payload['Keywords'] = invalid_keywords
      resp = Faraday.post(url, payload.to_json, "Content-Type" => "application/json")
      msg = "get_recommended_keywords - Calling external resource #{url}"
      msg += " with payload #{payload.to_json}."
      msg += " Response content=#{resp.body}"
      Rails.logger.info(msg)
      json = JSON.parse(resp.body)
      return json['Recommendations']
    rescue => e
      Rails.logger.error("get_recommended_keywords - Error retrieving recommended keywords, message=#{e.message}");
    end
  end

  def is_valid_keyword(keyword, scheme)
    if (!@keyword_paths_dict[scheme].nil?)
      return @keyword_paths_dict[scheme][keyword]
    end
    return false
  end

  def save_keywords(scheme, keyword_paths)
    keyword_hash = {}
    keyword_paths.each do |kp|
      keyword_hash[kp] = true
    end
    @keyword_paths_dict[scheme] = keyword_hash
  end

  def create_keyword_paths(scheme, csv_array)
    result = []
    i = get_keyword_index(scheme)
    csv_array.each do |n|
      path = ''
      if scheme == 'sciencekeywords'
        for j in 0..i
          if !n[j].blank?
            path += n[j].gsub("\"", '').strip
            path += '|'
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
    begin
      keywords = []
      url = get_kms_url(scheme)
      download = URI(url).open(ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE, encoding: 'UTF-8')
      CSV.new(download, liberal_parsing: true).each do |row|
        keywords << row
      end
      return keywords[2..keywords.length]
    rescue => e
      Rails.logger.error("download_keywords - Error retrieving kms keywords for scheme #{scheme}, message=#{e.message}");
    end
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

  def self.get_kms_base_url
    # commenting this out because mmt hardware can't access gcmd earthdata on sit.
    kms_base_url = Rails.application.config.kms_base_url
    if kms_base_url.nil?
      kms_base_url = 'https://gcmd.earthdata.nasa.gov'
    end
    kms_base_url
  end

  def get_kms_url(scheme)
    return Kms.get_kms_base_url() + "/kms/concepts/concept_scheme/#{scheme}?format=csv"
  end

  def get_recommended_keywords_url(scheme)
    return Kms.get_kms_base_url() + "/kms/recommended_keywords/?scheme=#{scheme}&includesFullPath=false"
  end

end