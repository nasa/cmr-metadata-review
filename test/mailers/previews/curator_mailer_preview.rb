class CuratorMailerPreview < ActionMailer::Preview

  def released_records_to
    CuratorMailer.released_records_to([User.first], [Record.first])
  end

end