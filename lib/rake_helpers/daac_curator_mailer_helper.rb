class DaacCuratorMailerOrchestration
  def self.released_records_digest_conductor(now: Time.now)
    emails_sent = 0
    current_recipients = ['daily']
    # wday returns 0-6 where 1 is Monday
    current_recipients << 'weekly' if now.wday == 1
    current_recipients << 'biweekly' if now.wday == 1 && ((1..7).to_a.include?(now.day) || (15..21).to_a.include?(now.day))
    current_recipients << 'monthly' if now.wday == 1 && (1..7).to_a.include?(now.day)

    daacs = User.where(role: 'daac_curator', email_preference: current_recipients).pluck(:daac).uniq

    # For each daac where anyone receives an e-mail...
    daacs.each do |daac|
      # Find relevant records or abort
      records = Record.where(state: :in_daac_review, daac: daac).order(released_to_daac_date: :desc)
      next if records.blank?

      # Find each curator who should receive an e-mail today
      recipients = User.where(email_preference: current_recipients, daac: daac)

      # Send e-mails
      DaacCuratorMailer.released_records_digest_notification(recipients, records, daac).deliver_now
      emails_sent += 1
    end
    emails_sent
  end
end