module Helpers
  module HomeHelper
    def see_collection_review_details(section, pos)
      # Select First Collection in In Arc Review
      within section do
        all('#record_id_')[pos].click # Selects the checkbox in "in arc review"
        find('div > div.navigate-buttons > input.selectButton').click # Clicks the See Review Details button
      end
    end
  end
end

