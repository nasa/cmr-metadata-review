require 'test_helper'

class MetricSetTest < ActiveSupport::TestCase

  context "color counts" do
    should "checks for color counts of record sets" do
      new_metric_set = MetricSet.new([(Record.find_by id: 10), (Record.find_by id: 11)])
      assert_equal({"blue"=>0, "green"=>0, "yellow"=>2, "red"=>2}, new_metric_set.color_counts)
    end
  end
end
