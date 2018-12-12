require 'test_helper'
Dir[Rails.root.join("test/**/*.rb")].each {|f| require f}

class UserTest < ActiveSupport::TestCase
  include OmniauthMacros

  describe "DAAC curator role" do

    it "is invalid without an associated DAAC" do
      user = users(:user2)
      user.role = "daac_curator"
      assert_not user.valid?
    end

  end

  describe "ARC curator role" do

    it "can see screen 'Awaiting Release to DAAC' but cannot release or delete a record" do
      arc_user = User.new
      arc_user.role = 'arc_curator'

      assert arc_user.role.eql?('arc_curator')

      ability = Ability.new(arc_user)
      #User should be able to access 'Awaiting Release to DAAC'
      assert ability.can?(:review_state, Record::STATE_READY_FOR_DAAC_REVIEW)
      #User should not be able to release a record to DAAC
      assert_not ability.can?(:release_to_daac, Record)
      #User should not be able to delete a record
      assert_not arc_user.admin

    end
  end

  describe "check active for authentication" do

    it "the account is active" do
      user = users(:user2)
      user.role = "daac_curator"
      stub_urs_access(user.uid, user.access_token, user.refresh_token)
      assert user.active_for_authentication? == true
    end

    it "the account is inactive" do
      user = users(:user2)
      user.role = "daac_curator"
      user.daac = 'LARC'
      user.access_token = 'accesstoken'
      user.refresh_token = 'refreshtoken'

      stub_urs_access(user.uid, user.access_token, user.refresh_token)
      stub_request(:get, "https://sit.urs.earthdata.nasa.gov/api/users/#{user.uid}?calling_application=clientid").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization'=>'Bearer '+user.access_token,
            'User-Agent'=>'Faraday v0.15.3'
          }).
        to_return(status: 401, body: '{"error":"invalid_token"}', headers: {})

      # The method below will even try to refresh the token, but
      # given the stub above says always return 401,
      # the user will still be deactivated.
      assert user.active_for_authentication? == false
    end
  end
end