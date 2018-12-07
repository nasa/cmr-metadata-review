require 'test_helper'

class UserTest < ActiveSupport::TestCase


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

      Cmr.stubs(:get_user_info).with{ |*args| args[0]}.returns [200, nil]
      assert user.active_for_authentication? == true
    end

    it "the account is inactive" do
      user = users(:user2)
      user.role = "daac_curator"
      user.daac = 'LARC'

      Cmr.stubs(:get_user_info).with{ |*args| args[0]}.returns [404, JSON.parse('{"error":"invalid_token"}')]
      Cmr.stubs(:get_access_token_and_refresh_token).with().returns ['[the access token]', '[the refresh token]']
      assert user.active_for_authentication? == false
    end


  end




end