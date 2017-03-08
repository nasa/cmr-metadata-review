require 'test_helper'

class RecordTest < ActiveSupport::TestCase

  it "returns correct attribute information for a record" do
    record = Record.find_by id: 1
    #had to remove description from yaml, json strings allow characters not allowed in yaml
    assert_equal(record.is_collection?, true)
    assert_equal(record.is_granule?, false)
    assert_equal(record.long_name, "NRT AMSR2 DAILY L3 GLOBAL SNOW WATER EQUIVALENT EASE-GRIDS")
    assert_equal(record.short_name, "A2_DySno_NRT")
    assert_equal(record.status_string, "In Process")
    assert_equal(record.concept_id, "C1000000020-LANCEAMSR2")

  end

  it "provides correct blank JSON layout from record" do
    record = Record.find_by id: 1
    assert_equal(record.blank_comment_JSON, "{\"ShortName\":\"\",\"VersionId\":\"\",\"InsertTime\":\"\",\"LastUpdate\":\"\",\"LongName\":\"\",\"DataSetId\":\"\",\"Description\":\"\",\"Price\":\"\",\"SpatialKeywords/Keyword\":\"\",\"TemporalKeywords/Keyword\":\"\",\"Temporal/RangeDateTime/BeginningDateTime\":\"\",\"Contacts/Contact/Role\":\"\",\"Contacts/Contact/OrganizationEmails/Email\":\"\",\"ScienceKeywords/ScienceKeyword0/CategoryKeyword\":\"\",\"ScienceKeywords/ScienceKeyword0/TopicKeyword\":\"\",\"ScienceKeywords/ScienceKeyword0/TermKeyword\":\"\",\"ScienceKeywords/ScienceKeyword0/VariableLevel1Keyword/Value\":\"\",\"ScienceKeywords/ScienceKeyword1/CategoryKeyword\":\"\",\"ScienceKeywords/ScienceKeyword1/TopicKeyword\":\"\",\"ScienceKeywords/ScienceKeyword1/TermKeyword\":\"\",\"ScienceKeywords/ScienceKeyword1/VariableLevel1Keyword/Value\":\"\",\"Platforms/Platform/ShortName\":\"\",\"Platforms/Platform/LongName\":\"\",\"Platforms/Platform/Type\":\"\",\"Platforms/Platform/Instruments/Instrument/ShortName\":\"\",\"Platforms/Platform/Instruments/Instrument/Sensors/Sensor/ShortName\":\"\",\"AdditionalAttributes/AdditionalAttribute0/Name\":\"\",\"AdditionalAttributes/AdditionalAttribute0/DataType\":\"\",\"AdditionalAttributes/AdditionalAttribute0/Description\":\"\",\"AdditionalAttributes/AdditionalAttribute0/Value\":\"\",\"AdditionalAttributes/AdditionalAttribute1/Name\":\"\",\"AdditionalAttributes/AdditionalAttribute1/DataType\":\"\",\"AdditionalAttributes/AdditionalAttribute1/Description\":\"\",\"AdditionalAttributes/AdditionalAttribute1/Value\":\"\",\"Campaigns/Campaign/ShortName\":\"\",\"OnlineAccessURLs/OnlineAccessURL/URL\":\"\",\"OnlineAccessURLs/OnlineAccessURL/URLDescription\":null,\"OnlineAccessURLs/OnlineAccessURL/MimeType\":null,\"OnlineResources/OnlineResource0/URL\":\"\",\"OnlineResources/OnlineResource0/Description\":null,\"OnlineResources/OnlineResource0/Type\":\"\",\"OnlineResources/OnlineResource1/URL\":\"\",\"OnlineResources/OnlineResource1/Description\":null,\"OnlineResources/OnlineResource1/Type\":\"\",\"OnlineResources/OnlineResource2/URL\":\"\",\"OnlineResources/OnlineResource2/Description\":null,\"OnlineResources/OnlineResource2/Type\":\"\",\"OnlineResources/OnlineResource3/URL\":\"\",\"OnlineResources/OnlineResource3/Description\":null,\"OnlineResources/OnlineResource3/Type\":\"\",\"OnlineResources/OnlineResource4/URL\":\"\",\"OnlineResources/OnlineResource4/Description\":null,\"OnlineResources/OnlineResource4/Type\":\"\",\"OnlineResources/OnlineResource5/URL\":\"\",\"OnlineResources/OnlineResource5/Description\":null,\"OnlineResources/OnlineResource5/Type\":\"\",\"OnlineResources/OnlineResource6/URL\":\"\",\"OnlineResources/OnlineResource6/Description\":null,\"OnlineResources/OnlineResource6/Type\":\"\",\"AssociatedDIFs/DIF/EntryId\":\"\",\"Spatial/SpatialCoverageType\":\"\",\"Spatial/HorizontalSpatialDomain/Geometry/CoordinateSystem\":\"\",\"Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle/WestBoundingCoordinate\":\"\",\"Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle/NorthBoundingCoordinate\":\"\",\"Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle/EastBoundingCoordinate\":\"\",\"Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle/SouthBoundingCoordinate\":\"\",\"Spatial/GranuleSpatialRepresentation\":\"\",\"MetadataStandardName\":\"\",\"MetadataStandardVersion\":\"\",\"DatasetId\":\"\",\"DataFormat\":\"\"}")
  end

  it "adds script results and can return them on command" do
    record = Record.find_by id: 1
    record.evaluate_script
    script_values = record.script_values
    assert_equal(script_values, {"ShortName"=>"OK", "VersionId"=>" OK", "InsertTime"=>" OK - quality check", "LastUpdate"=>" OK - quality check", "LongName"=>" Recommend that the Long Name use mixed case to optimize human readability..", "DataSetId"=>" Recommend changing the Dataset Id to mixed case to improve human readability.", "Description"=>" Dataset description may be inadequate", "Orderable"=>" based on length.", "Visible"=>" np", "RevisionDate"=>" np", "ProcessingCenter"=>" np", "ProcessingLevelId"=>" np", "ArchiveCenter"=>" Provide a processing level Id for this dataset. This is a required field.", "CitationForExternalPublication"=>" np", "CollectionState"=>" np", "DataFormat"=>" np", "SpatialKeywords/Keyword"=>" OK ", "Temporal/SingleDateTime"=>" Recommend providing a spatial keyword from the following keywords list: http://gcmdservices.gsfc.nasa.gov/static/kms/locations/locations.csv"})
    assert_equal(record.script_score, 5)
  end

  it "returns correct bubble map" do
    record = Record.find_by id: 1
    record.evaluate_script
    assert_equal(record.bubble_map, {"ShortName"=>{:field_name=>"ShortName", :color=>"white", :script=>false, :opinion=>false}, "VersionId"=>{:field_name=>"VersionId", :color=>"white", :script=>false, :opinion=>false}, "InsertTime"=>{:field_name=>"InsertTime", :color=>"white", :script=>false, :opinion=>false}, "LastUpdate"=>{:field_name=>"LastUpdate", :color=>"white", :script=>false, :opinion=>false}, "LongName"=>{:field_name=>"LongName", :color=>"white", :script=>true, :opinion=>false}, "DataSetId"=>{:field_name=>"DataSetId", :color=>"white", :script=>true, :opinion=>false}, "Description"=>{:field_name=>"Description", :color=>"white", :script=>true, :opinion=>false}, "Price"=>{:field_name=>"Price", :color=>"white", :script=>nil, :opinion=>false}, "SpatialKeywords/Keyword"=>{:field_name=>"SpatialKeywords/Keyword", :color=>"white", :script=>false, :opinion=>false}, "TemporalKeywords/Keyword"=>{:field_name=>"TemporalKeywords/Keyword", :color=>"white", :script=>nil, :opinion=>false}, "Temporal/RangeDateTime/BeginningDateTime"=>{:field_name=>"Temporal/RangeDateTime/BeginningDateTime", :color=>"white", :script=>nil, :opinion=>false}, "Contacts/Contact/Role"=>{:field_name=>"Contacts/Contact/Role", :color=>"white", :script=>nil, :opinion=>false}, "Contacts/Contact/OrganizationEmails/Email"=>{:field_name=>"Contacts/Contact/OrganizationEmails/Email", :color=>"white", :script=>nil, :opinion=>false}, "ScienceKeywords/ScienceKeyword0/CategoryKeyword"=>{:field_name=>"ScienceKeywords/ScienceKeyword0/CategoryKeyword", :color=>"white", :script=>nil, :opinion=>false}, "ScienceKeywords/ScienceKeyword0/TopicKeyword"=>{:field_name=>"ScienceKeywords/ScienceKeyword0/TopicKeyword", :color=>"white", :script=>nil, :opinion=>false}, "ScienceKeywords/ScienceKeyword0/TermKeyword"=>{:field_name=>"ScienceKeywords/ScienceKeyword0/TermKeyword", :color=>"white", :script=>nil, :opinion=>false}, "ScienceKeywords/ScienceKeyword0/VariableLevel1Keyword/Value"=>{:field_name=>"ScienceKeywords/ScienceKeyword0/VariableLevel1Keyword/Value", :color=>"white", :script=>nil, :opinion=>false}, "ScienceKeywords/ScienceKeyword1/CategoryKeyword"=>{:field_name=>"ScienceKeywords/ScienceKeyword1/CategoryKeyword", :color=>"white", :script=>nil, :opinion=>false}, "ScienceKeywords/ScienceKeyword1/TopicKeyword"=>{:field_name=>"ScienceKeywords/ScienceKeyword1/TopicKeyword", :color=>"white", :script=>nil, :opinion=>false}, "ScienceKeywords/ScienceKeyword1/TermKeyword"=>{:field_name=>"ScienceKeywords/ScienceKeyword1/TermKeyword", :color=>"white", :script=>nil, :opinion=>false}, "ScienceKeywords/ScienceKeyword1/VariableLevel1Keyword/Value"=>{:field_name=>"ScienceKeywords/ScienceKeyword1/VariableLevel1Keyword/Value", :color=>"white", :script=>nil, :opinion=>false}, "Platforms/Platform/ShortName"=>{:field_name=>"Platforms/Platform/ShortName", :color=>"white", :script=>nil, :opinion=>false}, "Platforms/Platform/LongName"=>{:field_name=>"Platforms/Platform/LongName", :color=>"white", :script=>nil, :opinion=>false}, "Platforms/Platform/Type"=>{:field_name=>"Platforms/Platform/Type", :color=>"white", :script=>nil, :opinion=>false}, "Platforms/Platform/Instruments/Instrument/ShortName"=>{:field_name=>"Platforms/Platform/Instruments/Instrument/ShortName", :color=>"white", :script=>nil, :opinion=>false}, "Platforms/Platform/Instruments/Instrument/Sensors/Sensor/ShortName"=>{:field_name=>"Platforms/Platform/Instruments/Instrument/Sensors/Sensor/ShortName", :color=>"white", :script=>nil, :opinion=>false}, "AdditionalAttributes/AdditionalAttribute0/Name"=>{:field_name=>"AdditionalAttributes/AdditionalAttribute0/Name", :color=>"white", :script=>nil, :opinion=>false}, "AdditionalAttributes/AdditionalAttribute0/DataType"=>{:field_name=>"AdditionalAttributes/AdditionalAttribute0/DataType", :color=>"white", :script=>nil, :opinion=>false}, "AdditionalAttributes/AdditionalAttribute0/Description"=>{:field_name=>"AdditionalAttributes/AdditionalAttribute0/Description", :color=>"white", :script=>nil, :opinion=>false}, "AdditionalAttributes/AdditionalAttribute0/Value"=>{:field_name=>"AdditionalAttributes/AdditionalAttribute0/Value", :color=>"white", :script=>nil, :opinion=>false}, "AdditionalAttributes/AdditionalAttribute1/Name"=>{:field_name=>"AdditionalAttributes/AdditionalAttribute1/Name", :color=>"white", :script=>nil, :opinion=>false}, "AdditionalAttributes/AdditionalAttribute1/DataType"=>{:field_name=>"AdditionalAttributes/AdditionalAttribute1/DataType", :color=>"white", :script=>nil, :opinion=>false}, "AdditionalAttributes/AdditionalAttribute1/Description"=>{:field_name=>"AdditionalAttributes/AdditionalAttribute1/Description", :color=>"white", :script=>nil, :opinion=>false}, "AdditionalAttributes/AdditionalAttribute1/Value"=>{:field_name=>"AdditionalAttributes/AdditionalAttribute1/Value", :color=>"white", :script=>nil, :opinion=>false}, "Campaigns/Campaign/ShortName"=>{:field_name=>"Campaigns/Campaign/ShortName", :color=>"white", :script=>nil, :opinion=>false}, "OnlineAccessURLs/OnlineAccessURL/URL"=>{:field_name=>"OnlineAccessURLs/OnlineAccessURL/URL", :color=>"white", :script=>nil, :opinion=>false}, "OnlineAccessURLs/OnlineAccessURL/URLDescription"=>{:field_name=>"OnlineAccessURLs/OnlineAccessURL/URLDescription", :color=>nil, :script=>nil, :opinion=>false}, "OnlineAccessURLs/OnlineAccessURL/MimeType"=>{:field_name=>"OnlineAccessURLs/OnlineAccessURL/MimeType", :color=>nil, :script=>nil, :opinion=>false}, "OnlineResources/OnlineResource0/URL"=>{:field_name=>"OnlineResources/OnlineResource0/URL", :color=>"white", :script=>nil, :opinion=>false}, "OnlineResources/OnlineResource0/Description"=>{:field_name=>"OnlineResources/OnlineResource0/Description", :color=>nil, :script=>nil, :opinion=>false}, "OnlineResources/OnlineResource0/Type"=>{:field_name=>"OnlineResources/OnlineResource0/Type", :color=>"white", :script=>nil, :opinion=>false}, "OnlineResources/OnlineResource1/URL"=>{:field_name=>"OnlineResources/OnlineResource1/URL", :color=>"white", :script=>nil, :opinion=>false}, "OnlineResources/OnlineResource1/Description"=>{:field_name=>"OnlineResources/OnlineResource1/Description", :color=>nil, :script=>nil, :opinion=>false}, "OnlineResources/OnlineResource1/Type"=>{:field_name=>"OnlineResources/OnlineResource1/Type", :color=>"white", :script=>nil, :opinion=>false}, "OnlineResources/OnlineResource2/URL"=>{:field_name=>"OnlineResources/OnlineResource2/URL", :color=>"white", :script=>nil, :opinion=>false}, "OnlineResources/OnlineResource2/Description"=>{:field_name=>"OnlineResources/OnlineResource2/Description", :color=>nil, :script=>nil, :opinion=>false}, "OnlineResources/OnlineResource2/Type"=>{:field_name=>"OnlineResources/OnlineResource2/Type", :color=>"white", :script=>nil, :opinion=>false}, "OnlineResources/OnlineResource3/URL"=>{:field_name=>"OnlineResources/OnlineResource3/URL", :color=>"white", :script=>nil, :opinion=>false}, "OnlineResources/OnlineResource3/Description"=>{:field_name=>"OnlineResources/OnlineResource3/Description", :color=>nil, :script=>nil, :opinion=>false}, "OnlineResources/OnlineResource3/Type"=>{:field_name=>"OnlineResources/OnlineResource3/Type", :color=>"white", :script=>nil, :opinion=>false}, "OnlineResources/OnlineResource4/URL"=>{:field_name=>"OnlineResources/OnlineResource4/URL", :color=>"white", :script=>nil, :opinion=>false}, "OnlineResources/OnlineResource4/Description"=>{:field_name=>"OnlineResources/OnlineResource4/Description", :color=>nil, :script=>nil, :opinion=>false}, "OnlineResources/OnlineResource4/Type"=>{:field_name=>"OnlineResources/OnlineResource4/Type", :color=>"white", :script=>nil, :opinion=>false}, "OnlineResources/OnlineResource5/URL"=>{:field_name=>"OnlineResources/OnlineResource5/URL", :color=>"white", :script=>nil, :opinion=>false}, "OnlineResources/OnlineResource5/Description"=>{:field_name=>"OnlineResources/OnlineResource5/Description", :color=>nil, :script=>nil, :opinion=>false}, "OnlineResources/OnlineResource5/Type"=>{:field_name=>"OnlineResources/OnlineResource5/Type", :color=>"white", :script=>nil, :opinion=>false}, "OnlineResources/OnlineResource6/URL"=>{:field_name=>"OnlineResources/OnlineResource6/URL", :color=>"white", :script=>nil, :opinion=>false}, "OnlineResources/OnlineResource6/Description"=>{:field_name=>"OnlineResources/OnlineResource6/Description", :color=>nil, :script=>nil, :opinion=>false}, "OnlineResources/OnlineResource6/Type"=>{:field_name=>"OnlineResources/OnlineResource6/Type", :color=>"white", :script=>nil, :opinion=>false}, "AssociatedDIFs/DIF/EntryId"=>{:field_name=>"AssociatedDIFs/DIF/EntryId", :color=>"white", :script=>nil, :opinion=>false}, "Spatial/SpatialCoverageType"=>{:field_name=>"Spatial/SpatialCoverageType", :color=>"white", :script=>nil, :opinion=>false}, "Spatial/HorizontalSpatialDomain/Geometry/CoordinateSystem"=>{:field_name=>"Spatial/HorizontalSpatialDomain/Geometry/CoordinateSystem", :color=>"white", :script=>nil, :opinion=>false}, "Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle/WestBoundingCoordinate"=>{:field_name=>"Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle/WestBoundingCoordinate", :color=>"white", :script=>nil, :opinion=>false}, "Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle/NorthBoundingCoordinate"=>{:field_name=>"Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle/NorthBoundingCoordinate", :color=>"white", :script=>nil, :opinion=>false}, "Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle/EastBoundingCoordinate"=>{:field_name=>"Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle/EastBoundingCoordinate", :color=>"white", :script=>nil, :opinion=>false}, "Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle/SouthBoundingCoordinate"=>{:field_name=>"Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle/SouthBoundingCoordinate", :color=>"white", :script=>nil, :opinion=>false}, "Spatial/GranuleSpatialRepresentation"=>{:field_name=>"Spatial/GranuleSpatialRepresentation", :color=>"white", :script=>nil, :opinion=>false}, "MetadataStandardName"=>{:field_name=>"MetadataStandardName", :color=>"white", :script=>nil, :opinion=>false}, "MetadataStandardVersion"=>{:field_name=>"MetadataStandardVersion", :color=>"white", :script=>nil, :opinion=>false}, "DatasetId"=>{:field_name=>"DatasetId", :color=>"white", :script=>nil, :opinion=>false}, "DataFormat"=>{:field_name=>"DataFormat", :color=>"white", :script=>true, :opinion=>false}})
  end

  it "catches incomplete record reviews" do
    record = Record.find_by id: 1
    assert_equal(record.color_coding_complete?, false)
    assert_equal(record.has_enough_reviews?, false)

    #testing again with only one color missing
    color_codes = record.get_colors.values
    color_codes.each_with_index do |(key, value), indexer|
      if indexer == 0
        color_codes[key] = "white"
      else
        color_codes[key] = "green"
      end
    end
    record.get_colors.update_values(color_codes)
    assert_equal(record.color_coding_complete?, false)

    #testing again with 1 review, 2 needed 
    first_review = record.add_review(1)
    first_review.mark_complete
    assert_equal(record.has_enough_reviews?, false)

    second_opinions = record.get_opinions
    opinion_values = second_opinions.values
    opinion_values["ShortName"] = true
    second_opinions.update_values(opinion_values)
    assert_equal(record.no_second_opinions?, false)
  end

  it "accepts complete reviews" do
    record = Record.find_by id: 1

    color_codes = record.color_codes
    color_codes.each do |key, value|
      color_codes[key] = "yellow"
    end
    record.get_colors.update_values(color_codes)
    assert_equal(record.color_coding_complete?, true)


    first_review = record.add_review(1)
    first_review.mark_complete
    second_review = record.add_review(2)
    second_review.mark_complete
    assert_equal(record.has_enough_reviews?, true)



    second_opinions = record.get_opinions
    opinion_values = second_opinions.values
    opinion_values["ShortName"] = false
    second_opinions.update_values(opinion_values)
    assert_equal(record.no_second_opinions?, true)
  end

end