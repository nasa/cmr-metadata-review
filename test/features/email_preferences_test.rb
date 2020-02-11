require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each {|f| require f}

class EmailPreferenceTest < Capybara::Rails::TestCase
  include Helpers::UserHelpers

  before do
    OmniAuth.config.test_mode = true
  end

  describe 'Accessing and updating e-mail preference' do
    before do
      mock_login(id: 5) # daac curator
    end

    it 'a daac curator can see and access the e-mail preferences page' do
      visit home_path
      assert has_content?('Account Options')
      find('.account_options').hover
      click_on('E-mail Preferences')
      assert has_content?('I would like the Curation Dashboard to send me e-mails summarizing available reports that are relevant to my DAAC:')
    end

    it 'a daac curator can save a preference' do
      visit email_preferences_path
      assert has_content?('I would like the Curation Dashboard to send me e-mails summarizing available reports that are relevant to my DAAC:')
      # Default should be never
      assert find('#email_preference_never').checked?
      choose 'Biweekly'
      click_on('Save Preferences')
      # Should load a new page and see that biweekly was saved
      assert find('#email_preference_biweekly').checked?
      choose 'Never'
      visit email_preferences_path
      # Didn't save the selection of never, so biweekly should still be selected
      assert find('#email_preference_biweekly').checked?
    end
  end
end
