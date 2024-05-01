require "test_helper"
Dir[Rails.root.join("test/**/*.rb")].each {|f| require f}

class CanAccessTopPageTest < SystemTestCase
  include OmniauthMacros

  # describe "POST #urs" do
    setup do
      OmniAuth.config.test_mode = true
      mock_normal_edl_user
      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user] # If using Devise
      Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:urs]
    end

    # describe "access top page" do
  test "can maps an EDL user to Devise user" do
        mock_existing_devise_user
        User.any_instance.stubs(:check_if_account_active).returns(true)
        AclDao.any_instance.stubs(:get_role_and_daac).with('existingdeviseuser').returns(['admin',nil])

        visit '/'
        find('#urs_login_button').click
        user = User.find_by_email("bjones@someplace.com")
        assert_equal(user.uid, 'existingdeviseuser')
        assert_equal(user.provider, 'urs')
        page.must_have_content("Logout")
        user = User.find_by_email("bjones@someplace.com")
        assert(user.uid == 'existingdeviseuser')
        assert(user.provider == 'urs')
      end
      test "can create a new user from an existing EDL user" do
        mock_new_devise_user

        User.any_instance.stubs(:check_if_account_active).returns(true)
        AclDao.any_instance.stubs(:get_role_and_daac).with('newdeviseuser').returns(['admin',nil])

        visit '/'
        find('#urs_login_button').click
        user = User.find_by_email("bsmith@someplace.com")
        assert(user != nil)
        page.must_have_content("Logout")
        user = User.find_by_email("bsmith@someplace.com")
        assert(user.uid == 'newdeviseuser')
        assert(user.provider == 'urs')
      end

      test "can sign in user with oauth account with admin privileges" do
        mock_normal_edl_user

        User.any_instance.stubs(:check_if_account_active).returns(true)
        AclDao.any_instance.stubs(:get_role_and_daac).with('normaluser').returns(['admin',nil])

        visit '/'
        find('#urs_login_button').click
        page.must_have_content("john smith")
        page.must_have_content("Logout")
        page.must_have_content("Account Options")
        page.must_have_content("Unreviewed Records:")
        page.must_have_content("In ARC Review Records:")
        page.must_have_content("Awaiting Release to DAAC:")
        page.must_have_content("In DAAC Review:")
        page.must_have_content("Requires Reviewer Feedback Records:")
      end

      test "can sign in user with oauth account with arc curator privileges" do
        mock_normal_edl_user

        User.any_instance.stubs(:check_if_account_active).returns(true)
        AclDao.any_instance.stubs(:get_role_and_daac).with('normaluser').returns(['arc_curator',nil])

        visit '/'
        find('#urs_login_button').click
        page.must_have_content("Logout")
        page.wont_have_content("Account Options")
        page.must_have_content("Unreviewed Records:")
        page.must_have_content("In ARC Review Records:")
        page.must_have_content("Awaiting Release to DAAC:")
        page.wont_have_content("In DAAC Review:")
        page.must_have_content("Requires Reviewer Feedback Records:")

      end

      test "can sign in user with oauth account with daac curator privileges" do
        mock_normal_edl_user
        User.any_instance.stubs(:check_if_account_active).returns(true)
        AclDao.any_instance.stubs(:get_role_and_daac).with('normaluser').returns(['daac_curator','LP_DAAC'])

        visit '/'

        find('#urs_login_button').click
        page.must_have_content("Logout")
        page.must_have_content("In DAAC Review:")
        page.must_have_content("Requires Reviewer Feedback Records:")
        page.wont_have_content("Unreviewed Records:")
      end

      test "it contains the invalid keywords report icon" do
        mock_normal_edl_user
        User.any_instance.stubs(:check_if_account_active).returns(true)
        AclDao.any_instance.stubs(:get_role_and_daac).with('normaluser').returns(['daac_curator','NSIDCV0'])

        visit '/'
        find('#urs_login_button').click
        find('.invalid_keywords_alert_icon').hover
        page.must_have_content('There are 1 invalid keywords found across 1 collection records')
      end

      test "can handle authentication error" do
        OmniAuth.config.mock_auth[:urs] = :invalid_credentials
        visit '/'
        find('#urs_login_button').click
        page.must_have_content('Could not authenticate you from URS because "Invalid credentials".')
      end
    # end
  # end
end
