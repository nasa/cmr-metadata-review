module SiteHelper
  def current_user_daac_records(records)
    daac_records = if current_user.daac_curator?
                     records.daac(current_user.daac)
                   else
                     records
                   end

    records_sorted_by_short_name(daac_records)
  end

  def curator_feedback_records(records)
    records.joins(:record_datas, :reviews).where(record_data: { feedback: true}, reviews: { user_id: current_user.id }).where.not(state: 'closed')
  end
end
