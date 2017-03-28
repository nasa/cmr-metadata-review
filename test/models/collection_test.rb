require 'test_helper'

class CollectionTest < ActiveSupport::TestCase

  describe "total_completed" do
    it "gets the number of unique collections in a completed state" do
      #set up a fixture with both a newer incomplete record and older incomplete to test filtering.
      assert_equal(Collection.total_completed, 1)
    end
  end

  describe "total_in_process" do
    it "gets the number of unique collections in the in process state" do
      #set up a fixture with both a newer incomplete record and older incomplete to test filtering.
      #also the first collection/record set used for other tests shows up as in process.
      assert_equal(Collection.total_in_process, 2)
    end
  end
end