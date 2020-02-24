class DaacCuratorMailer < ApplicationMailer
  def released_records_digest_notification(recipients, records, daac)
    @records = records
    @daac = daac

    recipient_array = recipients.map { |recipient| "#{recipient.name} <#{recipient.email}>" }

    mail(to: recipient_array, subject: "Summary of Reports Available to #{daac}")
  end
end