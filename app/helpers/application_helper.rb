module ApplicationHelper

  ANY_KEYWORD = 'Any'
  PROVIDERS = [ANY_KEYWORD, 'PODAAC', 'SEDAC', 'OB_DAAC', 'ORNL_DAAC', 'NSIDC_ECS', 'LAADS',
              'LPDAAC_ECS', 'GES_DISC','CDDIS', 'LARC_ASDC','ASF','GHRC'
              ]

  
  def provider_select_list
    provider_select_list = []
    PROVIDERS.each do |provider|
      provider_select_list.push([provider, provider])
    end
    provider_select_list  
  end

end
