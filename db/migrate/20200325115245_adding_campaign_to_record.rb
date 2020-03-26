class AddingCampaignToRecord < ActiveRecord::Migration[5.2]
  include RecordHelper
  def up
    add_column :records, :campaign, :string, array: true, default: [], null: false
    Record.all.each do |record|
      record.campaign = clean_up_campaign(record.record_datas.where(column_name: CAMPAIGN_COLUMNS).first.value)
      record.save
    end
  end

  def down
    remove_column :records, :campaign
  end
end
