require 'test_helper'

Dir[Rails.root.join("test/**/*.rb")].each {|f| require f}

# https://gist.github.com/kinopyo/1338738
class LoginControllerTest < ActionController::TestCase
  include OmniauthMacros

  describe "POST #urs" do
    before do
      mock_auth_hash
      request.env["devise.mapping"] = Devise.mappings[:user]
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:urs]
    end

    describe "#urs callback" do
      it "should successfully create a user" do
        mock_auth_hash
        before_count = User.count
        post :urs, provider: :urs
        after_count = User.count
        assert(after_count.must_equal(before_count + 1));
      end
    end

  end
end

