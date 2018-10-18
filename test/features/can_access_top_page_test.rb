require "test_helper"
Dir[Rails.root.join("test/**/*.rb")].each {|f| require f}

class CanAccessTopPageTest < Capybara::Rails::TestCase
  include OmniauthMacros

  describe "POST #urs" do
    before do
      OmniAuth.config.test_mode = true
      mock_auth_hash
      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user] # If using Devise
      Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:urs]
    end

    describe "access top page" do
      it "can sign in user with oauth account" do
        mock_auth_hash
        visit '/'
        page.must_have_content("Login with Earthdata Login")
        click_link "Login"
        page.must_have_content("Logout")
      end

      it "can handle authentication error" do
        OmniAuth.config.mock_auth[:urs] = :invalid_credentials
        visit '/'
        page.must_have_content("Login with Earthdata Login")
        click_link "Login"
        page.must_have_content('Could not authenticate you from URS because "Invalid credentials".')
      end
    end

  end
end
