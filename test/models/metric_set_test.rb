require 'test_helper'

class MetricSetTest < ActiveSupport::TestCase

  describe "color counts" do
    it "checks for color counts of record sets" do
      new_metric_set = MetricSet.new([(Record.find_by id: 10), (Record.find_by id: 11)])
      assert_equal({"blue"=>0, "green"=>0, "yellow"=>2, "red"=>2}, new_metric_set.color_counts)
    end
  end

  describe "red flags" do
    it "returns flag/red color hash" do
      new_metric_set = MetricSet.new([(Record.find_by id: 10), (Record.find_by id: 11)])
      assert_equal({"Accessibility"=>1, "Traceability"=>0, "Usability"=>1}, new_metric_set.red_flags)
    end
  end

  describe "total completed" do
    it "returns total completed number" do
      new_metric_set = MetricSet.new([(Record.find_by id: 10), (Record.find_by id: 11)])
      assert_equal(1, new_metric_set.total_completed)
    end
  end

  describe "total in process" do
    it "returns total in process count" do
      new_metric_set = MetricSet.new([(Record.find_by id: 10), (Record.find_by id: 11)])
      assert_equal(1, new_metric_set.total_in_process)
    end
  end

end