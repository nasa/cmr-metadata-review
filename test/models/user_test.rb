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

    it "can see the e-mail preferences page" do
      user = User.new
      user.id = 8
      user.role = 'daac_curator'

      ability = Ability.new(user)
      assert ability.can?(:update_email_preferences, user)
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
      assert_not arc_user.admin?
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

  describe "saving user email preferences" do
    it "can save user email preferences" do
      user = User.new(id: 8, role: 'daac_curator')
      assert user.email_preference == nil
      user.save_email_preference('biweekly')
      assert user.email_preference == 'biweekly'
      user.save_email_preference('never')
      assert user.email_preference == nil
    end
  end

  describe 'finding all the users and records to send digest e-mails' do
    describe 'when two different daacs need e-mails' do
      before do
        @user1 = User.find(8)
        @user1.daac = 'NSIDC'
        @user1.save
        @email_count = ActionMailer::Base.deliveries.count
      end

      after do
        @user1.daac = 'OB_DAAC'
        @user1.save
      end

      it 'sends two e-mails when two DAACs have records in review' do
        # This time is a second Monday, so it should trigger weekly/daily emails
        User.released_records_digest_conductor(now: Time.new(2020, 2, 10))

        assert_equal @email_count + 2, ActionMailer::Base.deliveries.count
        assert_equal [User.find(8).email], ActionMailer::Base.deliveries[@email_count].to
        assert_equal [User.find(7).email], ActionMailer::Base.deliveries[@email_count + 1].to
      end
    end

    describe 'when users with different preferences are processed' do
      before do
        @email_count = ActionMailer::Base.deliveries.count
      end

      it 'sends one email to one recipient on a Tuesday' do
        User.released_records_digest_conductor(now: Time.new(2020, 2, 4))

        assert_equal @email_count + 1, ActionMailer::Base.deliveries.count
        assert_equal [User.find(7).email], ActionMailer::Base.deliveries[@email_count].to
      end

      it 'sends one email to four recipients on the first Monday' do
        User.released_records_digest_conductor(now: Time.new(2020, 2, 3))

        assert_equal @email_count + 1, ActionMailer::Base.deliveries.count
        assert_equal [User.find(7).email, User.find(8).email, User.find(9).email, User.find(10).email], ActionMailer::Base.deliveries[@email_count].to
      end

      it 'sends one email to two recipients on the second Monday' do
        User.released_records_digest_conductor(now: Time.new(2020, 2, 10))

        assert_equal @email_count + 1, ActionMailer::Base.deliveries.count
        assert_equal [User.find(7).email, User.find(8).email], ActionMailer::Base.deliveries[@email_count].to
      end

      it 'sends one email to three recipients on the third Monday' do
        User.released_records_digest_conductor(now: Time.new(2020, 2, 17))

        assert_equal @email_count + 1, ActionMailer::Base.deliveries.count
        assert_equal [User.find(7).email, User.find(8).email, User.find(9).email], ActionMailer::Base.deliveries[@email_count].to
      end
    end
  end
end
