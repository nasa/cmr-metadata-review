require 'test_helper'

class DatableTest < ActiveSupport::TestCase

  it "fills in datable values if values are missing" do
    record = Record.find_by id: 1

    #This is to test the safety method of generating JSON for a datable object with no data.
    #should be unreachable due to initialization in the get_[data_type] methods
    #but still wanted to keep and test directly
    colors = Color.new(record: record)
    values = colors.values
    assert_equal(values["ShortName"], "")

  end
end