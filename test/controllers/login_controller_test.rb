require 'test_helper'

# https://gist.github.com/kinopyo/1338738
class LoginControllerTest < ActionController::TestCase

  def mock_auth_hash

    omniauth_hash = {'provider' => 'urs',
                     'uid' => '12345',
                     'info' => {
                       'first_name' => 'chris',
                       'last_name' => 'gokey',
                       'email' => 'cgokey@sgt-inc.com',
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
      mock_auth_hash
      request.env["devise.mapping"] = Devise.mappings[:user] # If using Devise
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:urs]
    end

    describe "#urs callback" do
      it "should successfully create a user" do
        mock_auth_hash
        before = User.count
        puts "#{User.count}"
        post :urs, provider: :urs
        after = User.count
        assert(after.must_equal(before + 1));
      end
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