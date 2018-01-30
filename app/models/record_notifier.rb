class RecordNotifier

<<<<<<< HEAD
  def self.notify_released(records)
    group_by_daac_curators(records) do | curators, daac_records |
      CuratorMailer.released_records(curators, daac_records).deliver_later
    end
  end

  def self.notify_closed(records)
    group_by_daac_curators(records) do | curators, daac_records |
      CuratorMailer.closed_records(curators, daac_records).deliver_later
    end
  end

  private

  def self.group_by_daac_curators(records)
    grouped_records = records.group_by { |r| r.daac }

    grouped_records.each do | daac, daac_records |
      curators = User.where(role: 'daac_curator', daac: daac).to_a

      if curators.size > 0
        yield curators, daac_records
=======
  def self.notify_daac_curators(records)
    records_by_daac = records.group_by { |r| r.daac }

    records_by_daac.each do | daac, daac_records |
      curators = User.where(role: 'daac_curator', daac: daac).to_a

      if curators.size > 0
        CuratorMailer.notify_curators(curators, records).deliver_later
>>>>>>> 1eb0701... [CMRARC-227]: Adds email notifications when records move to DAAC review.
      end
    end
  end

end