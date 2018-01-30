class CuratorMailer < ActionMailer::Base

  def notify_curators(users, records)
    @records = records

    mail(from: ENV['MAILER_SENDER'], to: users.map(&:email), subject: 'New Metadata Curation Tool Records Are Available')
  end

end