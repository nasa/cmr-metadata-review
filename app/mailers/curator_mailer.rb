class CuratorMailer < ActionMailer::Base

  def released_records(users, records)
    @records = records
    #mail(from: ENV['MAILER_SENDER'], to: users.map(&:email), subject: 'Metadata Curation Tool Released Records')
  end

  def closed_records(users, records)
    @records = records
    #mail(from: ENV['MAILER_SENDER'], to: users.map(&:email), subject: 'Metadata Curation Tool Closed Records')
  end

end