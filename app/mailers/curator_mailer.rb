class CuratorMailer < ActionMailer::Base

<<<<<<< HEAD
  def released_records(users, records)
    @records = records

    mail(from: ENV['MAILER_SENDER'], to: users.map(&:email), subject: 'Metadata Curation Tool Released Records')
  end

  def closed_records(users, records)
    @records = records

    mail(from: ENV['MAILER_SENDER'], to: users.map(&:email), subject: 'Metadata Curation Tool Closed Records')
=======
  def notify_curators(users, records)
    @records = records

    mail(from: ENV['MAILER_SENDER'], to: users.map(&:email), subject: 'New Metadata Curation Tool Records Are Available')
>>>>>>> 1eb0701... [CMRARC-227]: Adds email notifications when records move to DAAC review.
  end

end