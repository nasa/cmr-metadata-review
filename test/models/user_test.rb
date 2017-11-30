require 'test_helper'

class UserTest < ActiveSupport::TestCase

	describe "DAAC curator role" do

		it "is invalid without an associated DAAC" do
			user = users(:user2)
			user.role = "daac_curator"

			assert_not user.valid?
		end

	end

end