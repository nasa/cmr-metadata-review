require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  describe "GET #edit" do
    it "won't allow a user to edit email before signing in" do
      get :edit

      assert_redirected_to new_user_session_path
    end

    it "will allow access when the user is signed in" do
      sign_in(User.first)

      get :edit

      assert_response :success
    end
  end

  describe "PATCH #update" do
    it "won't allow a user to update without signing in" do
      patch :update, user: { email: "test1@element84.com" }

      assert_redirected_to new_user_session_path
    end

    it "will alert the user when the email can't be updated" do
      sign_in(User.first)

      patch :update, user: { email: "test@element84.com" }

      assert_equal "User could not be updated: Email has already been taken", flash[:alert]
      assert_template "edit"
    end

    it "will update the email address and redirect to the home page" do
      sign_in(User.first)

      User.any_instance.expects(:update_attributes).returns(true)

      patch :update, user: { email: "abaker+test1@element84.com" }

      assert_equal "User Email has been updated", flash[:notice]
      assert_redirected_to home_path
    end
  end
end
