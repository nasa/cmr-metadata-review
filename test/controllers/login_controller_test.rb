require 'test_helper'
Dir[Rails.root.join("test/**/*.rb")].each {|f| require f}

# https://gist.github.com/kinopyo/1338738
class LoginControllerTest < ActionController::TestCase
  include OmniauthMacros

  setup do
    @controller = LoginController.new
  end

  describe "POST #urs" do
    before do
      mock_normal_edl_user
      ENV['urs_site'] = 'https://sit.urs.earthdata.nasa.gov'
      ENV['urs_client_id'] = 'clientid'
      ENV['urs_client_secret'] = 'clientsecret'

      stub_request(:get, "#{Cmr.get_cmr_base_url}/access-control/acls?page_num=1&page_size=2000&permitted_user=normaluser").
        with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer accesstoken'
          }).
        to_return(status: 200, body: '{"hits":1,"took":661,"items":[{"revision_id":16,"concept_id":"ACL1200213993-CMR","identity_type":"Catalog Item","name":"Admin Full Access","location":"' + Cmr.get_cmr_base_url + ':443/access-control/acls/ACL1200213993-CMR"},{"revision_id":1,"concept_id":"ACL1200301610-CMR","identity_type":"System","name":"System - DASHBOARD_ARC_CURATOR","location":"' + Cmr.get_cmr_base_url + ':443/access-control/acls/ACL1200301610-CMR"}]}', headers: {})

      request.env["devise.mapping"] = Devise.mappings[:user]
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:urs]
    end


    describe "#urs callback" do
      it "should successfully create a user" do
        mock_normal_edl_user

        stub_request(:get, "https://sit.urs.earthdata.nasa.gov/api/users/normaluser?client_id=clientid").
          with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization' => 'Bearer accesstoken'
            }).
          to_return(status: 200, body: "{}", headers: {})

        before_count = User.count
        post :urs, params: { provider: :urs }
        after_count = User.count
        assert(after_count.must_equal(before_count + 1))
      end

      it "should set flash notice when user role is nil" do

        AclDao.any_instance.stubs(:get_role_and_daac).returns([nil, nil])

        post :urs, params: { provider: :urs }

        assert_equal "The user is not provisioned with the proper ACLs. Please contact User Support at support@earthdata.nasa.gov.", flash[:notice]
      end

      it "should set flash notice when CMR ACL request fails" do

        stub_request(:get, "#{Cmr.get_cmr_base_url}/access-control/acls?page_num=1&page_size=2000&permitted_user=normaluser")
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization' => 'Bearer accesstoken'
            })
          .to_return(status: 500)

        post :urs, params: { provider: :urs }

        assert_equal "Error retrieving ACLs from CMR for normaluser", flash[:notice]
      end
    end

  end
end

