class CuratorMailer < ApplicationMailer

  def released_records(users, records)
#    @records = records
#    mail(to: users.map(&:email), subject: 'Metadata Curation Tool Released Records')
  end

  def closed_records(users, records)
#    @records = records
#    mail(to: users.map(&:email), subject: 'Metadata Curation Tool Closed Records')
  end

end
