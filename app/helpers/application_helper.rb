module ApplicationHelper

  ANY_DAAC_KEYWORD = 'DAAC: ANY'
  ANY_CAMPAIGN_KEYWORD = 'CAMPAIGN: ANY'
  SELECT_DAAC = 'Select DAAC'

  #providers are specified to identify only the records within EOSDIS which ARC team curates
  ARC_PROVIDERS = ['NSIDCV0',
                   'ORNL_DAAC',
                   'LARC_ASDC',
                   'LARC',
                   'LAADS',
                   'GES_DISC',
                   'GHRC',
                   'SEDAC',
                   'ASF',
                   'LPDAAC_ECS',
                   'LANCEMODIS',
                   'NSIDC_ECS',
                   'OB_DAAC',
                   'CDDIS',
                   'LANCEAMSR2',
                   'PODAAC',
                   'ARCTEST']

  #providers are specified to identify only the records within EOSDIS which MDQ team curates
  MDQ_PROVIDERS = ['SCIOPS',
                   'NOAA_NCEI',
                   'JAXA',
                   'ISRO',
                   'AU_AADC',
                   'ESA',
                   'EUMETSA',
                   'MDQTEST']

  # The application mode is determined by the logged in user's role.   If they are a "mdq_curator" the mode will be :mdq_mode.
  # If they are an arc_curator, admin, the application_mode will be :arc_mode.   The mode will causing the filtering of
  # collections, granules based on a specific provider list.   
  def application_mode
    current_user.mdq_curator? ? :mdq_mode : :arc_mode
  end
  
  def provider_list
    application_mode == :mdq_mode ? MDQ_PROVIDERS : ARC_PROVIDERS
  end

  def provider_select_list()
    providers = daac_list(ANY_DAAC_KEYWORD)
    if Rails.env == 'production'
      providers.delete(%w[ARCTEST ARCTEST])
      providers.delete(%w[MDQTEST MDQTEST])
    end
    providers
  end

  def select_daac_list()
    providers = daac_list(SELECT_DAAC)
    if Rails.env == 'production'
      providers.delete(%w[ARCTEST ARCTEST])
      providers.delete(%w[MDQTEST MDQTEST])
    end
    providers
  end

  def string_html_format(string)
    sanitize(string, tags: %w(br a)).gsub(/(?:\n\r?|\r\n?)/, '<br>').html_safe
  end

  def records_sorted_by_short_name(records)
    records.sort_by do |record|
      record.recordable.short_name
    end
  end

  def campaign_select_list
    select_list = [ANY_CAMPAIGN_KEYWORD]

    camps = RecordData.select(:value).where(column_name: "Campaigns/Campaign/ShortName").where.not(value: "").order(:value).distinct
    select_list.concat(camps.map(&:value))

    select_list
  end

  private

  def daac_list(select_text)
    select_list = [select_text]
    if application_mode == :mdq_mode
      MDQ_PROVIDERS.each do |provider|
        select_list.push([provider, provider])
      end
    else
      ARC_PROVIDERS.each do |provider|
        select_list.push([provider, provider])
      end
    end
    select_list
  end

  def get_environment_display_name
    env_name = ENV['RAILS_ENV']
    if env_name != nil && env_name != 'production'
      "(#{env_name.upcase} Environment)"
    end
  end

  def self.truncate_string(string, max)
    string.length > max ? "#{string[0...max]}..." : string
  end

end
