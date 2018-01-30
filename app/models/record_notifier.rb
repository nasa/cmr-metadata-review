class RecordNotifier

  def self.notify_daac_curators(records)
    records_by_daac = records.group_by { |r| r.daac }

    records_by_daac.each do | daac, daac_records |
      curators = User.where(role: 'daac_curator', daac: daac).to_a

      if curators.size > 0
        CuratorMailer.notify_curators(curators, records).deliver_later
      end
    end
  end

end