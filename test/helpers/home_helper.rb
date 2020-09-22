module Helpers
  module HomeHelper
    def see_collection_review_details(section, revision_id)
      # Select First Collection in In Arc Review
      within section do
        find(:css, "#record_id_[value='#{revision_id}']").set(true)
        within '.navigate-buttons' do
          click_on 'See Review Detail'
        end
      end
    end
  end
end

