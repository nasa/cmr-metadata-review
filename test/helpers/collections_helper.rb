module Helpers
  module CollectionsHelper
    def associate_granule_to_collection(granule_id, collection_revision)
      within "#collection_revision_#{collection_revision}" do
        within "#form-#{collection_revision}" do
          first('#associated_granule_value').find("option[value='Undefined']").click # other tests are not cleaning up db, so reset it back manually
          first('#associated_granule_value').find("option[value='#{granule_id}']").click # Click in select box for what granule to associate
        end
      end
    end

    def see_collection_revision_details(collection_revision_id)
      within "#collection_revision_#{collection_revision_id}" do
        find('table > tbody > tr:nth-child(2) > td > div > div > div > form > button.smallSelectButton').click # click See Collection Review Details
      end
    end

    def see_granule_revision_details(granule_revision)
      # Click button to see Granule Review Details
      within "#granule_revision_#{granule_revision}" do
        find('#granule_review_link > form > button').click
      end
    end
  end
end

