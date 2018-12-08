require 'test_helper'
Dir[Rails.root.join("test/**/*.rb")].each {|f| require f}

# https://gist.github.com/kinopyo/1338738
class LoginControllerTest < ActionController::TestCase
  include OmniauthMacros

  setup do
    stub_urs_access
  end

  describe "POST #urs" do
    before do
      mock_auth_hash

      stub_request(:get, "#{Cmr.get_cmr_base_url}/access-control/acls?page_num=1&page_size=2000&permitted_user=12345").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Echo-Token'=>'12345:',
            'User-Agent'=>'Faraday v0.15.3'
          }).
        to_return(status: 200, body: '{"hits":1,"took":661,"items":[{"revision_id":16,"concept_id":"ACL1200213993-CMR","identity_type":"Catalog Item","name":"Admin Full Access","location":"'+Cmr.get_cmr_base_url+':443/access-control/acls/ACL1200213993-CMR"},{"revision_id":1,"concept_id":"ACL1200301610-CMR","identity_type":"System","name":"System - DASHBOARD_ARC_CURATOR","location":"'+Cmr.get_cmr_base_url+':443/access-control/acls/ACL1200301610-CMR"}]}', headers: {})

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

