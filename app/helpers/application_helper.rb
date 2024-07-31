module ApplicationHelper

  ANY_DAAC_KEYWORD = 'DAAC: ANY'
  ANY_CAMPAIGN_KEYWORD = 'CAMPAIGN/PROJECT: ANY'
  SELECT_DAAC = 'Select DAAC'

  #providers are specified to identify only the records within EOSDIS which ARC team curates
  ARC_PROVIDERS = [
                   'ORNL_DAAC',
                   'ASDC',
                   'LAADS',
                   'GES_DISC',
                   'GHRC',
                   'SEDAC',
                   'ASF',
                   'LPDAAC_ECS',
                   'LANCEMODIS',
                   'NSIDC',
                   'OB_CLOUD',
                   'OB_DAAC',
                   'CDDIS',
                   'PODAAC',
                   'OMINRT',
                   'ARCTEST',
                   'LM_FIRMS']

  #providers are specified to identify only the records within EOSDIS which MDQ team curates
  MDQ_PROVIDERS = ['SCIOPS',
                   'NOAA_NCEI',
                   'JAXA',
                   'ISRO',
                   'AU_AADC',
                   'ESA',
                   'EUMETSA',
                   'MDQTEST']

  # arc virtual providers and members of each virtual provider
  ARC_VIRTUAL_PROVIDERS = ['ASDC', 'LARC_ASDC', 'LARC', 'LARC_CLOUD',
                   'NSIDC', 'NSIDCV0', 'NSIDC_ECS',
                   'GHRC', 'GHRC_CLOUD', 'GHRC_DAAC', 'LANCEAMSR2',
                   'PODAAC', 'POCLOUD', 'PO.DAAC',
                   'ORNL_DAAC', 'ORNL_CLOUD',
                           'LPDAAC_ECS', 'LPCLOUD',
                           'GES_DISC', 'GESDISCCLD']

  # The application mode is determined by the logged in user's role or the associated daac.   If they are a
  # "mdq_curator" or a "daac_curator" who is associated with a daac in the MDQ_PROVIDERS list, then the mode will
  # be :mdq_mode. If they are an "arc_curator", "admin", or a "daac_curator" associated with a daac in the ARC_PROVIDERS
  # list the application_mode will be :arc_mode.   The mode will causing the filtering of collections, granules
  # based on a specific provider list.
  def application_mode
    current_user.mdq_user? ? :mdq_mode : :arc_mode
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

  def campaign_select_list(form:)
    select_list = [ANY_CAMPAIGN_KEYWORD]

    if current_user.daac_curator?
      daac = current_user.daac
      state = form == home_path ? :in_daac_review : [:finished, :closed]
    elsif current_user.mdq_curator?
      daac = MDQ_PROVIDERS
      state = form == home_path ? [:open, :in_arc_review, :ready_for_daac_review] : [:finished, :closed]
    elsif current_user.arc_curator?
      daac = ARC_PROVIDERS
      state = form == home_path ? [:open, :in_arc_review, :ready_for_daac_review] : [:finished, :closed]
    elsif current_user.admin?
      daac = ARC_PROVIDERS
      state = form == home_path ? [:open, :in_arc_review, :ready_for_daac_review, :in_daac_review] : [:finished, :closed]
    end

    select_list.concat(Record.where(daac: daac, state: state, recordable_type: 'Collection').pluck(:campaign).flatten.uniq.sort)

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

  def get_format_and_version(format, version)
    version = 'n/a' if version.nil?
    format == 'umm_json' ? "umm-c; version=#{version}" : format
  end

  def self.truncate_string(string, max)
    string.length > max ? "#{string[0...max]}..." : string
  end

  # convert the daac to virtual daac if necessary
  def self.virtual_daac(daac)
    daac = 'ASDC'   if %w[LARC_ASDC LARC LARC_CLOUD].include?(daac)
    daac = 'NSIDC'  if %w[NSIDCV0 NSIDC_ECS].include?(daac)
    daac = 'GHRC'   if %w[GHRC_CLOUD GHRC_DAAC LANCEAMSR2].include?(daac)
    daac = 'PODAAC' if %w[POCLOUD PO.DAAC].include?(daac)
    daac = 'ORNL_DAAC' if %w[ORNL_CLOUD].include?(daac)
    daac = 'LPDAAC_ECS' if %w[LPCLOUD].include?(daac)
    daac = 'GES_DISC' if %w[GESDISCCLD].include?(daac)
    daac
  end

  # convert virtual daac into a provider list
  def self.providers(virtual_daac)
    providers = virtual_daac
    providers = %w[ASDC LARC_ASDC LARC LARC_CLOUD] if virtual_daac == 'ASDC'
    providers = %w[NSIDC NSIDCV0 NSIDC_ECS] if virtual_daac == 'NSIDC'
    providers = %w[GHRC GHRC_CLOUD GHRC_DAAC LANCEAMSR2] if virtual_daac == 'GHRC'
    providers = %w[PODAAC POCLOUD PO.DAAC] if virtual_daac == 'PODAAC'
    providers = %w[ORNL_CLOUD ORNL_DAAC] if virtual_daac == 'ORNL_DAAC'
    providers = %w[LPDAAC_ECS LPCLOUD] if virtual_daac == 'LPDAAC_ECS'
    providers = %w[GES_DISC GESDISCCLD] if virtual_daac == 'GES_DISC'
    providers
  end

  def self.all_arc_providers
    return ARC_PROVIDERS + ARC_VIRTUAL_PROVIDERS
  end

  def all_providers
    application_mode == :mdq_mode ? MDQ_PROVIDERS : ARC_PROVIDERS + ARC_VIRTUAL_PROVIDERS
  end

  def pyquarc_version
    if Rails.env.test?
      return "test"
    end
    Quarc.instance.version
  end

end
