require "json"

class KeywordChecker
  SCHEMES = %w[sciencekeywords platforms instruments projects providers ProductLevelId]
  def initialize()
    @kms = Kms.new()
    @kms.download_kms_keywords(SCHEMES)
  end

  def get_invalid_keywords(json_record)
    record = JSON.parse(json_record)
    SCHEMES.each do |scheme|
      invalid_keywords = get_invalid_keywords_for_scheme(record, scheme)
      create_invalid_keyword_report(record, scheme, invalid_keywords) unless invalid_keywords.empty?
    end
  end

  def create_invalid_keyword_report(record, scheme, invalid_keywords)
    ummc_field = get_ummc_field(scheme)
    
  end

  def get_ummc_field(scheme)
    ummc_field = ''
    case scheme
    when 'sciencekeywords'
      ummc_field = 'ScienceKeywords'
    when 'platforms'
      ummc_field = 'Platforms'
    when 'instruments'
      ummc_field = 'Instruments'
    when 'projects'
      ummc_field = 'Projects'
    when 'providers'
      ummc_field = 'DataCenters'
    when 'ProductLevelId'
      ummc_field = 'ProcessingLevel'
    end
    return ummc_field
  end

  def get_invalid_keywords_for_scheme(record, scheme)
    valid_keywords = @kms.get_keyword_paths(scheme)
    record_keywords = get_record_keywords(record, scheme)
    invalid_record_keywords = get_unmatched(record_keywords, valid_keywords)
    return invalid_record_keywords
  end

  def get_record_keywords(record, scheme)
    keywords = []
    case scheme
    when 'sciencekeywords'
      if !record['ScienceKeywords'].nil?
        subTags = %w[Category Topic Term VariableLevel1 VariableLevel2 VariableLevel3 DetailedVariable]
        record['ScienceKeywords'].each do |sciencekw|
          kw = ''
          subTags.each do |subTag|
            kw += sciencekw[subTag] + '|' unless sciencekw[subTag].blank?
          end
          keywords << kw.chop
        end
      end
    when 'platforms'
      record['Platforms'].each {|platform| keywords << platform['ShortName']} unless record['Platforms'].nil?
    when 'instruments'
      if !record['Platforms'].nil?
        record['Platforms'].each do |platform|
          platform['Instruments'].each {|instrument| keywords << instrument['ShortName']} unless platform['Instruments'].nil?
        end
      end
    when 'projects'
      record['Projects'].each {|project| keywords << project['ShortName']} unless record['Projects'].nil?
    when 'providers'
      record['DataCenters'].each {|dataCenter| keywords << dataCenter['ShortName']} unless record['DataCenters'].nil?
    when 'ProductLevelId'
      keywords << record['ProcessingLevel']['Id'] unless record['ProcessingLevel'].nil?
    end
    return keywords
  end

  def get_unmatched(keywords, valid_keywords)
    unmatched = []
    keywords.each do |kw|
      found = valid_keywords.detect {|e| e == kw}
      unmatched << kw unless found
    end
    return unmatched
  end

end