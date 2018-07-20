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

end