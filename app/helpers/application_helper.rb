module ApplicationHelper

  ANY_KEYWORD = 'DAAC: ANY'
  #providers are specified to identify only the records within EOSDIS
  PROVIDERS = ['NSIDCV0',
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
              'PODAAC']

  
  def provider_select_list
    provider_select_list = [ANY_KEYWORD]
    PROVIDERS.each do |provider|
      provider_select_list.push([provider, provider])
    end
    provider_select_list  
  end

end
