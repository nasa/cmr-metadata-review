require "test_helper"
Dir[Rails.root.join("test/**/*.rb")].each {|f| require f}

class CanAccessTopPageTest < Capybara::Rails::TestCase
  include OmniauthMacros

  describe "POST #urs" do
    before do
      OmniAuth.config.test_mode = true
      mock_normal_edl_user
      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user] # If using Devise
      Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:urs]

      stub_urs_access('normaluser', 'accesstoken', 'refreshtoken')
      stub_urs_access('existingdeviseuser', 'accesstoken', 'refreshtoken')
      stub_urs_access('newdeviseuser', 'accesstoken', 'refreshtoken')

      stub_request(:get, "#{Cmr.get_cmr_base_url}/access-control/acls?page_num=1&page_size=2000&permitted_user=normaluser").
        with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Echo-Token' => 'accesstoken:clientid',
            'User-Agent' => 'Faraday v0.15.3'
          }).
        to_return(status: 200, body: '{"hits":1,"took":661,"items":[{"revision_id":16,"concept_id":"ACL1200213993-CMR","identity_type":"Catalog Item","name":"Admin Full Access","location":"' + Cmr.get_cmr_base_url + ':443/access-control/acls/ACL1200213993-CMR"}, {"revision_id":1,"concept_id":"ACL1200301611-CMR","identity_type":"System","name":"System - DASHBOARD_ADMIN","location":"' + Cmr.get_cmr_base_url + ':443/access-control/acls/ACL1200301611-CMR"}]}', headers: {})
    end

    describe "access top page" do
      it "can maps an EDL user to Devise user" do
        mock_existing_devise_user

        stub_request(:get, "#{Cmr.get_cmr_base_url}/access-control/acls?page_num=1&page_size=2000&permitted_user=existingdeviseuser").
          with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Echo-Token' => 'accesstoken:clientid',
              'User-Agent' => 'Faraday v0.15.3'
            }).
          to_return(status: 200, body: '{"hits":1,"took":661,"items":[{"revision_id":16,"concept_id":"ACL1200213993-CMR","identity_type":"Catalog Item","name":"Admin Full Access","location":"' + Cmr.get_cmr_base_url + ':443/access-control/acls/ACL1200213993-CMR"},{"revision_id":1,"concept_id":"ACL1200301611-CMR","identity_type":"System","name":"System - DASHBOARD_ADMIN","location":"' + Cmr.get_cmr_base_url + ':443/access-control/acls/ACL1200301611-CMR"}]}', headers: {})

        visit '/'
        page.must_have_content("Login with Earthdata Login")
        user = User.find_by_email("bjones@someplace.com")
        assert(user.uid == nil)
        assert(user.provider == nil)
        click_link "Login"
        page.must_have_content("Logout")
        user = User.find_by_email("bjones@someplace.com")
        assert(user.uid == 'existingdeviseuser')
        assert(user.provider == 'urs')
      end
      it "can create a new user from an existing EDL user" do
        mock_new_devise_user

        stub_request(:get, "#{Cmr.get_cmr_base_url}/access-control/acls?page_num=1&page_size=2000&permitted_user=newdeviseuser").
          with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Echo-Token' => 'accesstoken:clientid',
              'User-Agent' => 'Faraday v0.15.3'
            }).
          to_return(status: 200, body: '{"hits":1,"took":661,"items":[{"revision_id":16,"concept_id":"ACL1200213993-CMR","identity_type":"Catalog Item","name":"Admin Full Access","location":"' + Cmr.get_cmr_base_url + ':443/access-control/acls/ACL1200213993-CMR"},{"revision_id":1,"concept_id":"ACL1200301611-CMR","identity_type":"System","name":"System - DASHBOARD_ADMIN","location":"' + Cmr.get_cmr_base_url + ':443/access-control/acls/ACL1200301611-CMR"}]}', headers: {})

        visit '/'
        page.must_have_content("Login with Earthdata Login")
        user = User.find_by_email("bsmith@someplace.com")
        assert(user == nil)
        click_link "Login"
        page.must_have_content("Logout")
        user = User.find_by_email("bsmith@someplace.com")
        assert(user.uid == 'newdeviseuser')
        assert(user.provider == 'urs')
      end

      it "can sign in user with oauth account with admin privileges" do
        mock_normal_edl_user

        stub_request(:get, "#{Cmr.get_cmr_base_url}/access-control/acls?page_num=1&page_size=2000&permitted_user=normaluser").
          with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Echo-Token' => 'accesstoken:clientid',
              'User-Agent' => 'Faraday v0.15.3'
            }).
          to_return(status: 200, body: '{"hits":1,"took":661,"items":[{"revision_id":16,"concept_id":"ACL1200213993-CMR","identity_type":"Catalog Item","name":"Admin Full Access","location":"' + Cmr.get_cmr_base_url + ':443/access-control/acls/ACL1200213993-CMR"},{"revision_id":1,"concept_id":"ACL1200301611-CMR","identity_type":"System","name":"System - DASHBOARD_ADMIN","location":"' + Cmr.get_cmr_base_url + ':443/access-control/acls/ACL1200301611-CMR"}]}', headers: {})

        visit '/'
        page.must_have_content("Login with Earthdata Login")
        click_link "Login"
        page.must_have_content("Logout")
        page.must_have_content("Account Options")
        page.must_have_content("Unreviewed Records:")
        page.must_have_content("In ARC Review Records:")
        page.must_have_content("Awaiting Release to DAAC:")
        page.must_have_content("In DAAC Review:")
        page.must_have_content("Requires Curator Feedback Records:")
      end

      it "can sign in user with oauth account with arc curator privileges" do
        mock_normal_edl_user

        stub_request(:get, "#{Cmr.get_cmr_base_url}/access-control/acls?page_num=1&page_size=2000&permitted_user=normaluser").
          with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Echo-Token' => 'accesstoken:clientid',
              'User-Agent' => 'Faraday v0.15.3'
            }).
          to_return(status: 200, body: '{"hits":1,"took":661,"items":[{"revision_id":16,"concept_id":"ACL1200213993-CMR","identity_type":"Catalog Item","name":"Admin Full Access","location":"' + Cmr.get_cmr_base_url + ':443/access-control/acls/ACL1200213993-CMR"},{"revision_id":1,"concept_id":"ACL1200301610-CMR","identity_type":"System","name":"System - DASHBOARD_ARC_CURATOR","location":"' + Cmr.get_cmr_base_url + ':443/access-control/acls/ACL1200301610-CMR"}]}', headers: {})

        visit '/'
        page.must_have_content("Login with Earthdata Login")
        click_link "Login"
        page.must_have_content("Logout")
        page.wont_have_content("Account Options")
        page.must_have_content("Unreviewed Records:")
        page.must_have_content("In ARC Review Records:")
        page.must_have_content("Awaiting Release to DAAC:")
        page.wont_have_content("In DAAC Review:")
        page.must_have_content("Requires Curator Feedback Records:")

      end

      it "can sign in user with oauth account with daac curator privileges" do
        mock_normal_edl_user

        stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/access-control/acls/ACL1200303063-CMR").
          with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Echo-Token' => 'accesstoken:clientid',
              'User-Agent' => 'Faraday v0.15.3'
            }).
          to_return(status: 200, body: '{"group_permissions":[{"group_id":"AG1200303062-LARC","permissions":["create"]},{"group_id":"AG1200301542-CMR","permissions":["create"]},{"group_id":"AG1200303012-CMR","permissions":["create"]}],"provider_identity":{"target":"DASHBOARD_DAAC_CURATOR","provider_id":"LARC"}}', headers: {})

        stub_request(:get, "#{Cmr.get_cmr_base_url}/access-control/acls?page_num=1&page_size=2000&permitted_user=normaluser").
          with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Echo-Token' => 'accesstoken:clientid',
              'User-Agent' => 'Faraday v0.15.3'
            }).
          to_return(status: 200, body: '{"hits":1,"took":661,"items":[{"revision_id":3,"concept_id":"ACL1200303063-CMR","identity_type":"Provider","name":"Provider - LARC - DASHBOARD_DAAC_CURATOR","location":"' + Cmr.get_cmr_base_url + ':443/access-control/acls/ACL1200303063-CMR"}]}', headers: {})
        visit '/'
        page.must_have_content("Login with Earthdata Login")
        click_link "Login"
        page.must_have_content("Logout")
        page.must_have_content("In DAAC Review:")
        page.must_have_content("Requires Curator Feedback Records:")
        page.wont_have_content("Unreviewed Records:")
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
