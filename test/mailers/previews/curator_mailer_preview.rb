class CuratorMailerPreview < ActionMailer::Preview

  def released_records
    CuratorMailer.released_records([User.first], [Record.first])
  end

  def closed_records
    CuratorMailer.closed_records([User.first], [Record.first])
  end

end