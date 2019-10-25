module Helpers
  module UserHelpers
    # by passes devise methods needed to login
    # you can pass either id or uid or role and will return the user.
    def mock_login(id: nil, uid: nil, role: nil)
      user = User.find_by role: role unless role == nil
      user = User.find_by uid: uid unless uid == nil
      user = User.find_by id: id unless id == nil
      ApplicationController.any_instance.stubs(:authenticate_user!).returns(true)
      ApplicationController.any_instance.stubs(:user_signed_in).returns(true)
      ApplicationController.any_instance.stubs(:current_user).returns(user)
    end

    def finished_all_jQuery_requests?
      # puts "checking jQuery requests. no active calls? #{page.evaluate_script('jQuery.active').zero?}"
      page.evaluate_script('jQuery.active').zero?
    end

  end
end
