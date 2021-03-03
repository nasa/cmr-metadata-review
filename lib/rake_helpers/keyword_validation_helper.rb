class KeywordValidation
  def self.validate_keywords()
    print('Starting cron job Keyword Validator')
    keywordValidator = KeywordValidator.new
    keywordValidator.validate_keywords
    print('Ended cron job Keyword Validator')
  end
end