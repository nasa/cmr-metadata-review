class CuratorMailer < ActionMailer::Base

  def released_records(users, records)
#    @records = records
#    mail(from: ENV['mailer_sender'], to: users.map(&:email), subject: 'Metadata Curation Tool Released Records')
  end

  def closed_records(users, records)
#    @records = records
#    mail(from: ENV['mailer_sender'], to: users.map(&:email), subject: 'Metadata Curation Tool Closed Records')
  end

end