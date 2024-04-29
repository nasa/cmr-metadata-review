require 'test_helper'

class DocumentAmendmentsTest < ActiveSupport::TestCase
  include DocumentAmendmentsHelper
  context 'test setting default values' do
    before do
      @object = JSON.load({
                            "alpha": {
                              "beta": {
                                "value": "foo",
                                "gamma": {
                                }
                              }
                            }
                          }.to_json).to_hash
    end
    should 'can assign n/a at 2 levels deep' do
      Cmr.dig_and_set_na(@object, ["alpha", "value"])
      assert_equal(@object, { "alpha" => { "beta" => { "value" => "foo", "gamma" => {} }, "value" => "N/A" } })
    end
    should 'can assign n/a at 3 levels deep' do
      Cmr.dig_and_set_na(@object, ["alpha", "beta", "gamma", "delta", "value"])
      assert_equal(@object, { "alpha" => { "beta" => { "value" => "foo", "gamma" => { "delta" => { "value" => "N/A" } } } } })
    end
    should 'will only assign n/a to values not set' do
      Cmr.dig_and_set_na(@object, ["alpha", "beta", "value"])
      assert_equal(@object, { "alpha" => { "beta" => { "value" => "foo", "gamma" => {} } } })
    end
    should 'will work properly with an empty document' do
      object = {}
      Cmr.dig_and_set_na(object, ["alpha", "beta", "value"])
      assert_equal(object, {"alpha"=>{"beta"=>{"value"=>"N/A"}}})
    end
  end

end

