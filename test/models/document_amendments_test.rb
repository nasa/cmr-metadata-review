require 'test_helper'

class DocumentAmendmentsTest < ActiveSupport::TestCase
  include DocumentAmendmentsHelper
  # context 'test setting default values' do
  setup do
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
  test 'can assign n/a at 2 levels deep' do
      Cmr.dig_and_set_na(@object, ["alpha", "value"])
      assert_equal(@object, { "alpha" => { "beta" => { "value" => "foo", "gamma" => {} }, "value" => "N/A" } })
    end
  test 'can assign n/a at 3 levels deep' do
      Cmr.dig_and_set_na(@object, ["alpha", "beta", "gamma", "delta", "value"])
      assert_equal(@object, { "alpha" => { "beta" => { "value" => "foo", "gamma" => { "delta" => { "value" => "N/A" } } } } })
    end
  test 'will only assign n/a to values not set' do
      Cmr.dig_and_set_na(@object, ["alpha", "beta", "value"])
      assert_equal(@object, { "alpha" => { "beta" => { "value" => "foo", "gamma" => {} } } })
    end
  test 'will work properly with an empty document' do
      object = {}
      Cmr.dig_and_set_na(object, ["alpha", "beta", "value"])
      assert_equal(object, {"alpha"=>{"beta"=>{"value"=>"N/A"}}})
    end
  # end

end

