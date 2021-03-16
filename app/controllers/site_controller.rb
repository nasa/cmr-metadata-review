class SiteController < ApplicationController
  include SiteHelper

  before_action :authenticate_user!, :except => [:elb_status]
  before_action :ensure_curation, :except => [:general_home, :elb_status]

  def home
    unless session[:unhide_record_ids].nil?
      @unhide_record_ids = {}
      @unhide_record_ids[session[:unhide_state]] = session[:unhide_record_ids]
      session[:unhide_record_ids] = nil
      session[:unhide_state] = nil
    end

    provider =  current_user.daac_curator? ? current_user.daac : nil
    @invalid_keywords = InvalidKeyword.get_invalid_keywords(ApplicationHelper::providers(provider))

    records = Record.where(daac: nil)
    return if records.count.zero?

    Rails.logger.info("Found #{records.count} record(s) which do not have a DAAC. All records should have a DAAC, please investigate the source of this.")
    records.each do |record|
      Rails.logger.info("Record without DAAC: #{record.inspect}")
    end
  end

  def general_home
    if current_user
      sign_out current_user
    end
    redirect_to home_path
  end

  def elb_status
    render :json => {"elb_status" => "ok" }
  end
end
