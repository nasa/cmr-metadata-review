class AclsController < ApplicationController
  before_action :authenticate_user!

  def index
    acl = AclDao.new(current_user.access_token, ENV['urs_client_id'], Cmr.get_cmr_base_url)
    @user_id = params['user_id']
    @groups = acl.get_all_groups(@user_id)
  end
end
