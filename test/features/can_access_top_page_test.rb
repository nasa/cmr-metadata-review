require "test_helper"

class CanAccessTopPageTest < Capybara::Rails::TestCase
  def mock_auth_hash
    omniauth_hash = {'provider' => 'urs',
                     'uid' => '12345',
                     'info' => {
                       'first_name' => 'chris',
                       'last_name' => 'gokey',
                       'email_address' => 'cgokey@sgt-inc.com',
                     },
                     'extra' => {'raw_info' =>
                                   {'user_type' => 'my_user_type',
                                    'organization' => 'NASA'
                                   }
                     }
    }
    OmniAuth.config.add_mock(:urs, omniauth_hash)
  end

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
        page.must_have_content("Login with Earth Data Login")
        click_link "Login"
        page.must_have_content("Logout")
      end

      it "can handle authentication error" do
        OmniAuth.config.mock_auth[:urs] = :invalid_credentials
        visit '/'
        page.must_have_content("Login with Earth Data Login")
        click_link "Login"
        page.must_have_content('Could not authenticate you from URS because "Invalid credentials".')
      end
    end

  end
end
