module SiteHelper
  include ApplicationHelper
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

  def title_for_in_review_records()
    if application_mode == :mdq_mode
      'In MDQ Review Records'
    else
      'In ARC Review Records'
    end
  end

  # Count Second Opinions here for every record
  def second_opinion_count(records)
    RecordData.where(record: records, opinion: true).group(:record_id).count
  end

end
