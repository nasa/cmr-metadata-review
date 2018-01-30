class CuratorMailerPreview < ActionMailer::Preview

<<<<<<< HEAD
  def released_records
    CuratorMailer.released_records([User.first], [Record.first])
  end

  def closed_records
    CuratorMailer.closed_records([User.first], [Record.first])
=======
  def released_records_to
    CuratorMailer.released_records_to([User.first], [Record.first])
>>>>>>> 1eb0701... [CMRARC-227]: Adds email notifications when records move to DAAC review.
  end

end