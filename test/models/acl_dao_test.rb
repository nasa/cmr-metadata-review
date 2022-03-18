require 'test_helper'
require 'stub_data'

class AclDaoTest < ActiveSupport::TestCase
  setup do
    ENV['urs_site'] = 'https://sit.urs.earthdata.nasa.gov'
    ENV['urs_client_id'] = 'clientid'
    ENV['urs_client_secret'] = 'clientsecret'

    @cmr_base_url = Cmr.get_cmr_base_url
  end

  describe "test acls" do
    it "tests retrieving role as admin" do
      stub_request(:get, "#{Cmr.get_cmr_base_url}/access-control/acls?page_num=1&page_size=2000&permitted_user=existingdeviseuser").
        with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer accesstoken'
          }).
        to_return(status: 200, body: '{"hits":1,"took":661,"items":[{"revision_id":16,"concept_id":"ACL1200213993-CMR","identity_type":"Catalog Item","name":"Admin Full Access","location":"' + Cmr.get_cmr_base_url + ':443/access-control/acls/ACL1200213993-CMR"},{"revision_id":1,"concept_id":"ACL1200301611-CMR","identity_type":"System","name":"System - DASHBOARD_ADMIN","location":"' + Cmr.get_cmr_base_url + ':443/access-control/acls/ACL1200301611-CMR"}]}', headers: {})

      acl = AclDao.new('accesstoken', ENV['urs_client_id'], @cmr_base_url)
      role, daac = acl.get_role_and_daac('existingdeviseuser')
      assert_equal('admin', role)
      assert_nil(daac)
    end

    it "tests retrieving role as arc_curator" do
      stub_request(:get, "#{Cmr.get_cmr_base_url}/access-control/acls?page_num=1&page_size=2000&permitted_user=normaluser").
        with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer accesstoken'
          }).
        to_return(status: 200, body: '{"hits":1,"took":661,"items":[{"revision_id":16,"concept_id":"ACL1200213993-CMR","identity_type":"Catalog Item","name":"Admin Full Access","location":"' + Cmr.get_cmr_base_url + ':443/access-control/acls/ACL1200213993-CMR"},{"revision_id":1,"concept_id":"ACL1200301610-CMR","identity_type":"System","name":"System - DASHBOARD_ARC_CURATOR","location":"' + Cmr.get_cmr_base_url + ':443/access-control/acls/ACL1200301610-CMR"}]}', headers: {})

      acl = AclDao.new('accesstoken', ENV['urs_client_id'], @cmr_base_url)
      role, daac = acl.get_role_and_daac('normaluser')
      assert_equal('arc_curator', role)
      assert_nil(daac)
    end

    it 'tests retrieving acls as daac curator' do
      stub_request(:get, "#{@cmr_base_url}/access-control/acls/ACL1200303063-CMR").
        with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer accesstoken'
          }).
        to_return(status: 200, body: '{"group_permissions":[{"group_id":"AG1200303062-LARC","permissions":["create"]},{"group_id":"AG1200301542-CMR","permissions":["create"]},{"group_id":"AG1200303012-CMR","permissions":["create"]}],"provider_identity":{"target":"DASHBOARD_DAAC_CURATOR","provider_id":"LARC"}}', headers: {})

      stub_request(:get, "#{Cmr.get_cmr_base_url}/access-control/acls?page_num=1&page_size=2000&permitted_user=normaluser").
        with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer accesstoken'
          }).
        to_return(status: 200, body: '{"hits":1,"took":661,"items":[{"revision_id":3,"concept_id":"ACL1200303063-CMR","identity_type":"Provider","name":"Provider - LARC - DASHBOARD_DAAC_CURATOR","location":"' + Cmr.get_cmr_base_url + ':443/access-control/acls/ACL1200303063-CMR"}]}', headers: {})

      acl = AclDao.new('accesstoken', ENV['urs_client_id'], @cmr_base_url)
      role, daac = acl.get_role_and_daac('normaluser')
      assert_equal('daac_curator', role)
      assert_equal(daac, 'LARC')
    end
  end
end
