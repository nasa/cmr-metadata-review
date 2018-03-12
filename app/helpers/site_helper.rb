module SiteHelper
  def records_sorted_by_short_name(records)
    records.sort_by do |record|
      record.recordable.short_name
    end
  end

  def current_user_daac_records(records)
    daac_records = if current_user.role.eql?("daac_curator")
      records.daac(current_user.daac)
    else
      records
    end

    records_sorted_by_short_name(daac_records)
  end

  def currator_feedback_records(records)
    records.joins(:record_datas, :reviews).where(record_data: { feedback: true}, reviews: { user_id: current_user.id })
  end
end
