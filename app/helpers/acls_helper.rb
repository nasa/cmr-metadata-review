module AclsHelper
  def is_non_nasa_draft_approver?(user:, token:)
    # code here
  end

  def link_for_groups_in_mmt(concept_id)
    env_name = ENV.fetch('RAILS_ENV', '').downcase
    case env_name
    when 'sit', 'development', 'test'
      "https://mmt.sit.earthdata.nasa.gov/groups/#{concept_id}/edit"
    when 'uat'
      "https://mmt.uat.earthdata.nasa.gov/groups/#{concept_id}/edit"
    else
      "https://mmt.earthdata.nasa.gov/groups/#{concept_id}/edit"
    end
  end

  def link_for_system_identity_permissions(concept_id)
    env_name = ENV.fetch('RAILS_ENV', '').downcase
    case env_name
    when 'sit', 'development', 'test'
      "https://mmt.sit.earthdata.nasa.gov/system_identity_permissions/#{concept_id}/edit"
    when 'uat'
      "https://mmt.uat.earthdata.nasa.gov/system_identity_permissions/#{concept_id}/edit"
    else
      "https://mmt.earthdata.nasa.gov/system_identity_permissions/#{concept_id}/edit"
    end
  end

  def link_for_provider_identity_permissions(concept_id)
    env_name = ENV.fetch('RAILS_ENV', '').downcase
    case env_name
    when 'sit', 'development', 'test'
      "https://mmt.sit.earthdata.nasa.gov/provider_identity_permissions/#{concept_id}/edit"
    when 'uat'
      "https://mmt.uat.earthdata.nasa.gov/provider_identity_permissions/#{concept_id}/edit"
    else
      "https://mmt.earthdata.nasa.gov/provider_identity_permissions/#{concept_id}/edit"
    end
  end

end
