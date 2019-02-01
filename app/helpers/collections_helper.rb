# frozen_string_literal: true

require 'action_view/helpers/javascript_helper'
require 'active_support/core_ext/array/access'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/string/output_safety'

module CollectionsHelper

  # indicator used by the view to tell the user if the granule has been deleted from cmr
  def indicator_for_granule_deleted_in_cmr(granule)
    granule.deleted_in_cmr ? '[Granule Not Found in CMR]' : ''
  end

  # indicator used by the view to tell the user if a new granule revision has come available in cmr.
  def indicator_for_has_new_granule_revision(granule)
    return '' if granule.deleted_in_cmr
    highest_revision_id = 0
    granule.records.each do |granule_record|
      revision_id = granule_record.revision_id.to_i
      highest_revision_id = revision_id if revision_id > highest_revision_id
    end
    if highest_revision_id < granule.latest_revision_in_cmr.to_i
      if can?(:create_granule, Collection)
        return link_to("Import New Revision #{granule.latest_revision_in_cmr}",
                     pull_latest_granule_path(granule.id),
                     method: :post, class: 'import_new_revision',
                     data: { confirm: 'Are you sure?' })
      else
        return content_tag('span', "[Latest Revision #{granule.latest_revision_in_cmr}]")
      end
    else
      return ''
    end
  end


end