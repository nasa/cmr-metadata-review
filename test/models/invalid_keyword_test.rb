require 'test_helper'

class InvalidKeywordTest < ActiveSupport::TestCase
  describe "test creating invalid keywords and removing all invalid keywords by provider" do
    it "create an invalid keyword" do
      all_invalid_keywords = InvalidKeyword.all
      count = all_invalid_keywords.length
      keyword = InvalidKeyword.create_invalid_keyword(DateTime.new(), "LARC", "39393_LARC", 1,  "ShortName", "Version",
                                            "ScienceKeywords|ATMOPHERE|AEROSLS", nil, "ScienceKeywords"
                                            )
      success = keyword.save
      assert(success, true)
      all_invalid_keywords = InvalidKeyword.all
      new_count = all_invalid_keywords.length
      assert_equal(count+1, new_count)
    end
  end
  it "remove invalid keywords by provider" do
    all_invalid_keywords = InvalidKeyword.all
    before_count = all_invalid_keywords.length
    InvalidKeyword.remove_all_invalid_keywords("LARC")
    all_invalid_keywords = InvalidKeyword.all
    after_count = all_invalid_keywords.length
    assert(before_count-1, after_count)
  end
end
