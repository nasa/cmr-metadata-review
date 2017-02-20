require 'test_helper'

class Users::RegistrationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  
  # test "redirect non admins from sign up" do
  #   user = users(:nonadmin)
  #   sign_in user

  #   #suggested by devise, required due to overriding of registrations
  #   @request.env["devise.mapping"] = Devise.mappings[:user]
  #   get :new

  #   assert_equal(response.status, 302)
  #   assert_redirected_to :root
  # end

  # test "don't redirect admins from sign up" do
  #   user = users(:admin)
  #   sign_in user

  #   #suggested by devise, required due to overriding of registrations
  #   @request.env["devise.mapping"] = Devise.mappings[:user]
  #   get :new

  #   assert_equal(response.status, 200)
  # end

end
