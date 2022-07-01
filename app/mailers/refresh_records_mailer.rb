class RefreshRecordsMailer < ApplicationMailer
  def release_refreshed_records(recipients, added_records, failed_records, deleted_records)
    @added_records = added_records
    @failed_records = failed_records
    @deleted_records = deleted_records
    time = Time.new
    timestamp = time.strftime("%d/%m/%Y %I:%M %p")
    mail(to: recipients, subject: "Summary of Refresh Records on #{timestamp}")
  end
end
