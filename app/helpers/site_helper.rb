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

  def title_for_in_review_records()
    if application_mode == :mdq_mode
      'In MDQ Review Records'
    else
      'In ARC Review Records'
    end
  end

  def filter_records(records)
    records = if current_user.daac_curator?
                 Record.daac(current_user.daac)
               elsif filtered_by?(:daac, ANY_DAAC_KEYWORD)
                 Record.daac(params[:daac])
               else
                 Record.all_records(application_mode)
               end
    # only include collection records
    records = records.where(recordable_type: 'Collection').distinct
    records = records.where("'#{params[:campaign]}' = ANY (campaign)") if filtered_by?(:campaign, ANY_CAMPAIGN_KEYWORD)
    records
  end

  # Count Second Opinions here for every record
  def second_opinion_count(records)
    RecordData.where(record: records, opinion: true).group(:record_id).count
  end


end
