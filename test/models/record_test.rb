require 'test_helper'
require 'stub_data'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class RecordTest < ActiveSupport::TestCase
  include Helpers::RecordHelpers
  include RecordHelper

  setup do
    @cmr_base_url = Cmr.get_cmr_base_url
  end

  describe "test remove_quotes_from_all_values" do
    it "successfully removes quotes in 3+ levels deep." do
      example = { foo: { bar: { value: 'my "value"', alpha: { beta: 'my "gamma"' } } } }
      assert_equal(example[:foo][:bar][:value], 'my "value"')
      assert_equal(example[:foo][:bar][:alpha][:beta], 'my "gamma"')
      remove_quotes_from_all_values!(example)
      assert_equal(example[:foo][:bar][:value], 'my value')
      assert_equal(example[:foo][:bar][:alpha][:beta], 'my gamma')
    end
  end


  describe "attribute accessor methods" do
    it "returns correct attribute information for a record" do
      record = Record.find_by id: 1
      #had to remove description from yaml, json strings allow characters not allowed in yaml
      assert_equal(record.collection?, true)
      assert_equal(record.granule?, false)
      assert_equal(record.long_name, "Test_Long_Name")
      assert_equal(record.short_name, "A2_DySno_NRT")
      assert_equal(record.status_string, "In Process")
      assert_equal(record.concept_id, "C1000000020-LANCEAMSR2")
      assert_equal(record.version_id, "0")
      assert_equal(record.ingested_by, "abaker@element84.com")
    end
  end

  describe "script_values && script_score" do
    it "adds script results and can return them on command" do
      record = Record.find_by id: 1

      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/concepts/C1000000020-LANCEAMSR2.echo10").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: DEPENDENT_COLLECTION, headers: {})

      #stubbing all requests for raw_data
      stub_request(:get, "#{@cmr_base_url}/search/collections.echo10?concept_id=C1000000020-LANCEAMSR2").with(:headers => { 'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'}).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><results><hits>1</hits><took>14</took><result concept-id=\"C1000000020-LANCEAMSR2\" revision-id=\"8\" format=\"application/echo10+xml\">\n<Collection>\n<ShortName>A2_DySno_NRT</ShortName>\n<VersionId>0</VersionId>\n<InsertTime>2015-05-01T13:26:43Z</InsertTime>\n<LastUpdate>2015-09-14T13:26:43Z</LastUpdate>\n<LongName>NRT AMSR2 DAILY L3 GLOBAL SNOW WATER EQUIVALENT EASE-GRIDS</LongName>\n<DataSetId>NRT AMSR2 DAILY L3 GLOBAL SNOW WATER EQUIVALENT EASE-GRIDS V0</DataSetId>\n<Description>The Advanced Microwave Scanning Radiometer 2 (AMSR2) instrument on the Global Change Observation Mission - Water 1 (GCOM-W1) provides global passive microwave measurements of terrestrial, oceanic, and atmospheric parameters for the investigation of global water and energy cycles.  Near real-time (NRT) products are generated within 3 hours of the last observations in the file, by the Land Atmosphere Near real-time Capability for EOS (LANCE) at the AMSR Science Investigator-led Processing System (AMSR SIPS), which is collocated with the Global Hydrology Resource Center (GHRC) DAAC.  The GCOM-W1 AMSR2 Level-3 Snow Water Equivalent (SWE) data set contains snow water equivalent (SWE) data and quality assurance flags mapped to Northern and Southern Hemisphere 25 km Equal-Area Scalable Earth Grids (EASE-Grids).  Data are stored in HDF-EOS5 format and are available via HTTP from the EOSDIS LANCE system at https://lance.nsstc.nasa.gov/amsr2-science/data/level3/daysnow/R00/hdfeos5/.  If data latency is not a primary concern, please consider using science quality products.  Science products are created using the best available ancillary, calibration and ephemeris information.  Science quality products are an internally consistent, well-calibrated record of the Earth's geophysical properties to support science.  The AMSR SIPS plans to start producing initial AMSR2 standard science quality data products in late 2015 and they will be available from the NSIDC DAAC.  Notice: All LANCE AMSR2 data should be used with the understanding that these are preliminary products.  Cross calibration with AMSR-E products has not been performed.  As updates are made to the L1R data set, those changes will be reflected in this higher level product.</Description>\n<CollectionDataType>NEAR_REAL_TIME</CollectionDataType>\n<Orderable>false</Orderable>\n<Visible>true</Visible>\n<ProcessingLevelId>3</ProcessingLevelId>\n<ArchiveCenter>GHRC</ArchiveCenter>\n<CitationForExternalPublication>Tedesco, M., J. Jeyaratnam, and R. Kelly. 2015. NRT AMSR2 Daily L3 Global Snow Water Equivalent EASE-Grids [indicate subset used]. Dataset available online, [https://lance.nsstc.nasa.gov/amsr2-science/data/level3/daysnow/R00/hdfeos5/] from NASA LANCE AMSR2 at the GHRC DAAC Huntsville, Alabama, U.S.A. doi: http://dx.doi.org/10.5067/AMSR2/A2_DySno_NRT</CitationForExternalPublication><Price>0.0</Price><SpatialKeywords>\n<Keyword>GLOBAL</Keyword></SpatialKeywords><TemporalKeywords>\n<Keyword>DAILY</Keyword></TemporalKeywords><Temporal><RangeDateTime>\n<BeginningDateTime>2015-05-01T00:00:00Z</BeginningDateTime></RangeDateTime></Temporal><Contacts><Contact>\n<Role>GHRC USER SERVICES</Role><OrganizationEmails>\n<Email>ghrc-dmg@itsc.uah.edu</Email></OrganizationEmails></Contact></Contacts><ScienceKeywords><ScienceKeyword>\n<CategoryKeyword>EARTH SCIENCE</CategoryKeyword>\n<TopicKeyword>CRYOSPHERE</TopicKeyword>\n<TermKeyword>SNOW/ICE</TermKeyword><VariableLevel1Keyword>\n<Value>SNOW WATER EQUIVALENT</Value></VariableLevel1Keyword></ScienceKeyword><ScienceKeyword>\n<CategoryKeyword>EARTH SCIENCE</CategoryKeyword>\n<TopicKeyword>TERRESTRIAL HYDROSPHERE</TopicKeyword>\n<TermKeyword>SNOW/ICE</TermKeyword><VariableLevel1Keyword>\n<Value>SNOW WATER EQUIVALENT</Value></VariableLevel1Keyword></ScienceKeyword></ScienceKeywords><Platforms><Platform>\n<ShortName>GCOM-W1</ShortName>\n<LongName>GCOM-W1</LongName>\n<Type>SATELLITE</Type><Instruments><Instrument>\n<ShortName>AMSR2</ShortName><Sensors><Sensor>\n<ShortName>AMSR2</ShortName></Sensor></Sensors></Instrument></Instruments></Platform></Platforms>\n<AdditionalAttributes>\n<AdditionalAttribute>\n<Name>identifier_product_doi</Name>\n<DataType>STRING</DataType>\n<Description>product DOI</Description>\n<Value>10.5067/AMSR2/A2_DySno_NRT</Value>\n</AdditionalAttribute>\n<AdditionalAttribute>\n<Name>identifier_product_doi_authority</Name>\n<DataType>STRING</DataType>\n<Description>DOI authority</Description>\n<Value>http://dx.doi.org</Value>\n</AdditionalAttribute>\n</AdditionalAttributes>\n<Campaigns><Campaign>\n<ShortName>LANCE</ShortName></Campaign></Campaigns><OnlineAccessURLs><OnlineAccessURL>\n<URL>https://lance.nsstc.nasa.gov/amsr2-science/data/level3/daysnow/R00/hdfeos5/</URL><URLDescription></URLDescription><MimeType></MimeType></OnlineAccessURL></OnlineAccessURLs><OnlineResources><OnlineResource>\n<URL>https://lance.itsc.uah.edu/amsr2-science/data/level3/daysnow/R00/hdfeos5/</URL><Description></Description>\n<Type>Alternate Data Access</Type></OnlineResource><OnlineResource>\n<URL>https://lance.nsstc.nasa.gov/amsr2-science/browse_png/level3/daysnow/R00/</URL><Description></Description>\n<Type>Browse</Type></OnlineResource><OnlineResource>\n<URL>https://worldview.earthdata.nasa.gov/</URL><Description></Description>\n<Type>Worldview Imagery</Type></OnlineResource><OnlineResource>\n<URL>http://lance.nsstc.nasa.gov/</URL><Description></Description>\n<Type>Homepage</Type></OnlineResource><OnlineResource>\n<URL>http://lance.nsstc.nasa.gov/amsr2-science/doc/LANCE_A2_DySno_NRT_dataset.pdf</URL><Description></Description>\n<Type>Guide</Type></OnlineResource><OnlineResource>\n<URL>http://dx.doi.org/10.5067/AMSR2/A2_DySno_NRT</URL><Description></Description>\n<Type>DOI</Type></OnlineResource><OnlineResource>\n<URL>http://ghrc.nsstc.nasa.gov/uso/citation.html</URL><Description></Description>\n<Type>Citing GHRC Data</Type></OnlineResource></OnlineResources><AssociatedDIFs><DIF>\n<EntryId>A2_DySno_NRT</EntryId></DIF></AssociatedDIFs><Spatial><SpatialCoverageType>Horizontal</SpatialCoverageType><HorizontalSpatialDomain><Geometry>\n<CoordinateSystem>CARTESIAN</CoordinateSystem><BoundingRectangle>\n<WestBoundingCoordinate>-180</WestBoundingCoordinate>\n<NorthBoundingCoordinate>90</NorthBoundingCoordinate>\n<EastBoundingCoordinate>180</EastBoundingCoordinate>\n<SouthBoundingCoordinate>-90</SouthBoundingCoordinate></BoundingRectangle></Geometry></HorizontalSpatialDomain>\n<GranuleSpatialRepresentation>CARTESIAN</GranuleSpatialRepresentation></Spatial>\n<MetadataStandardName>ECHO</MetadataStandardName>\n<MetadataStandardVersion>10</MetadataStandardVersion>\n</Collection></result></results>", :headers => { "date"=>["Tue, 21 Feb 2017 16:02:46 GMT"], "content-type"=>["application/echo10+xml; charset=utf-8"], "access-control-expose-headers"=>["CMR-Hits, CMR-Request-Id"], "access-control-allow-origin"=>["*"], "cmr-hits"=>["10554"], "cmr-took"=>["40"], "cmr-request-id"=>["5b0c8426-3a23-4025-a4d3-6d1c9024153a"], "vary"=>["Accept-Encoding, User-Agent"], "connection"=>["close"], "server"=>["Jetty(9.2.z-SNAPSHOT)"] })

      record.create_script
      script_values = record.script_values
      assert_equal(script_values, { "LongName"=>"ok", "ShortName"=>"ok", "VersionId"=>"ok" })
    end
  end

  describe "bubble_map" do
    it "returns correct bubble map" do
      record = Record.find_by id: 1

      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/concepts/C1000000020-LANCEAMSR2.echo10").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: DEPENDENT_COLLECTION, headers: {})

      #stubbing all requests for raw_data
      stub_request(:get, "#{@cmr_base_url}/search/collections.echo10?concept_id=C1000000020-LANCEAMSR2").with(:headers => { 'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3' }).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><results><hits>1</hits><took>14</took><result concept-id=\"C1000000020-LANCEAMSR2\" revision-id=\"8\" format=\"application/echo10+xml\">\n<Collection>\n<ShortName>A2_DySno_NRT</ShortName>\n<VersionId>0</VersionId>\n<InsertTime>2015-05-01T13:26:43Z</InsertTime>\n<LastUpdate>2015-09-14T13:26:43Z</LastUpdate>\n<LongName>NRT AMSR2 DAILY L3 GLOBAL SNOW WATER EQUIVALENT EASE-GRIDS</LongName>\n<DataSetId>NRT AMSR2 DAILY L3 GLOBAL SNOW WATER EQUIVALENT EASE-GRIDS V0</DataSetId>\n<Description>The Advanced Microwave Scanning Radiometer 2 (AMSR2) instrument on the Global Change Observation Mission - Water 1 (GCOM-W1) provides global passive microwave measurements of terrestrial, oceanic, and atmospheric parameters for the investigation of global water and energy cycles.  Near real-time (NRT) products are generated within 3 hours of the last observations in the file, by the Land Atmosphere Near real-time Capability for EOS (LANCE) at the AMSR Science Investigator-led Processing System (AMSR SIPS), which is collocated with the Global Hydrology Resource Center (GHRC) DAAC.  The GCOM-W1 AMSR2 Level-3 Snow Water Equivalent (SWE) data set contains snow water equivalent (SWE) data and quality assurance flags mapped to Northern and Southern Hemisphere 25 km Equal-Area Scalable Earth Grids (EASE-Grids).  Data are stored in HDF-EOS5 format and are available via HTTP from the EOSDIS LANCE system at https://lance.nsstc.nasa.gov/amsr2-science/data/level3/daysnow/R00/hdfeos5/.  If data latency is not a primary concern, please consider using science quality products.  Science products are created using the best available ancillary, calibration and ephemeris information.  Science quality products are an internally consistent, well-calibrated record of the Earth's geophysical properties to support science.  The AMSR SIPS plans to start producing initial AMSR2 standard science quality data products in late 2015 and they will be available from the NSIDC DAAC.  Notice: All LANCE AMSR2 data should be used with the understanding that these are preliminary products.  Cross calibration with AMSR-E products has not been performed.  As updates are made to the L1R data set, those changes will be reflected in this higher level product.</Description>\n<CollectionDataType>NEAR_REAL_TIME</CollectionDataType>\n<Orderable>false</Orderable>\n<Visible>true</Visible>\n<ProcessingLevelId>3</ProcessingLevelId>\n<ArchiveCenter>GHRC</ArchiveCenter>\n<CitationForExternalPublication>Tedesco, M., J. Jeyaratnam, and R. Kelly. 2015. NRT AMSR2 Daily L3 Global Snow Water Equivalent EASE-Grids [indicate subset used]. Dataset available online, [https://lance.nsstc.nasa.gov/amsr2-science/data/level3/daysnow/R00/hdfeos5/] from NASA LANCE AMSR2 at the GHRC DAAC Huntsville, Alabama, U.S.A. doi: http://dx.doi.org/10.5067/AMSR2/A2_DySno_NRT</CitationForExternalPublication><Price>0.0</Price><SpatialKeywords>\n<Keyword>GLOBAL</Keyword></SpatialKeywords><TemporalKeywords>\n<Keyword>DAILY</Keyword></TemporalKeywords><Temporal><RangeDateTime>\n<BeginningDateTime>2015-05-01T00:00:00Z</BeginningDateTime></RangeDateTime></Temporal><Contacts><Contact>\n<Role>GHRC USER SERVICES</Role><OrganizationEmails>\n<Email>ghrc-dmg@itsc.uah.edu</Email></OrganizationEmails></Contact></Contacts><ScienceKeywords><ScienceKeyword>\n<CategoryKeyword>EARTH SCIENCE</CategoryKeyword>\n<TopicKeyword>CRYOSPHERE</TopicKeyword>\n<TermKeyword>SNOW/ICE</TermKeyword><VariableLevel1Keyword>\n<Value>SNOW WATER EQUIVALENT</Value></VariableLevel1Keyword></ScienceKeyword><ScienceKeyword>\n<CategoryKeyword>EARTH SCIENCE</CategoryKeyword>\n<TopicKeyword>TERRESTRIAL HYDROSPHERE</TopicKeyword>\n<TermKeyword>SNOW/ICE</TermKeyword><VariableLevel1Keyword>\n<Value>SNOW WATER EQUIVALENT</Value></VariableLevel1Keyword></ScienceKeyword></ScienceKeywords><Platforms><Platform>\n<ShortName>GCOM-W1</ShortName>\n<LongName>GCOM-W1</LongName>\n<Type>SATELLITE</Type><Instruments><Instrument>\n<ShortName>AMSR2</ShortName><Sensors><Sensor>\n<ShortName>AMSR2</ShortName></Sensor></Sensors></Instrument></Instruments></Platform></Platforms>\n<AdditionalAttributes>\n<AdditionalAttribute>\n<Name>identifier_product_doi</Name>\n<DataType>STRING</DataType>\n<Description>product DOI</Description>\n<Value>10.5067/AMSR2/A2_DySno_NRT</Value>\n</AdditionalAttribute>\n<AdditionalAttribute>\n<Name>identifier_product_doi_authority</Name>\n<DataType>STRING</DataType>\n<Description>DOI authority</Description>\n<Value>http://dx.doi.org</Value>\n</AdditionalAttribute>\n</AdditionalAttributes>\n<Campaigns><Campaign>\n<ShortName>LANCE</ShortName></Campaign></Campaigns><OnlineAccessURLs><OnlineAccessURL>\n<URL>https://lance.nsstc.nasa.gov/amsr2-science/data/level3/daysnow/R00/hdfeos5/</URL><URLDescription></URLDescription><MimeType></MimeType></OnlineAccessURL></OnlineAccessURLs><OnlineResources><OnlineResource>\n<URL>https://lance.itsc.uah.edu/amsr2-science/data/level3/daysnow/R00/hdfeos5/</URL><Description></Description>\n<Type>Alternate Data Access</Type></OnlineResource><OnlineResource>\n<URL>https://lance.nsstc.nasa.gov/amsr2-science/browse_png/level3/daysnow/R00/</URL><Description></Description>\n<Type>Browse</Type></OnlineResource><OnlineResource>\n<URL>https://worldview.earthdata.nasa.gov/</URL><Description></Description>\n<Type>Worldview Imagery</Type></OnlineResource><OnlineResource>\n<URL>http://lance.nsstc.nasa.gov/</URL><Description></Description>\n<Type>Homepage</Type></OnlineResource><OnlineResource>\n<URL>http://lance.nsstc.nasa.gov/amsr2-science/doc/LANCE_A2_DySno_NRT_dataset.pdf</URL><Description></Description>\n<Type>Guide</Type></OnlineResource><OnlineResource>\n<URL>http://dx.doi.org/10.5067/AMSR2/A2_DySno_NRT</URL><Description></Description>\n<Type>DOI</Type></OnlineResource><OnlineResource>\n<URL>http://ghrc.nsstc.nasa.gov/uso/citation.html</URL><Description></Description>\n<Type>Citing GHRC Data</Type></OnlineResource></OnlineResources><AssociatedDIFs><DIF>\n<EntryId>A2_DySno_NRT</EntryId></DIF></AssociatedDIFs><Spatial><SpatialCoverageType>Horizontal</SpatialCoverageType><HorizontalSpatialDomain><Geometry>\n<CoordinateSystem>CARTESIAN</CoordinateSystem><BoundingRectangle>\n<WestBoundingCoordinate>-180</WestBoundingCoordinate>\n<NorthBoundingCoordinate>90</NorthBoundingCoordinate>\n<EastBoundingCoordinate>180</EastBoundingCoordinate>\n<SouthBoundingCoordinate>-90</SouthBoundingCoordinate></BoundingRectangle></Geometry></HorizontalSpatialDomain>\n<GranuleSpatialRepresentation>CARTESIAN</GranuleSpatialRepresentation></Spatial>\n<MetadataStandardName>ECHO</MetadataStandardName>\n<MetadataStandardVersion>10</MetadataStandardVersion>\n</Collection></result></results>", :headers => { "date"=>["Tue, 21 Feb 2017 16:02:46 GMT"], "content-type"=>["application/echo10+xml; charset=utf-8"], "access-control-expose-headers"=>["CMR-Hits, CMR-Request-Id"], "access-control-allow-origin"=>["*"], "cmr-hits"=>["10554"], "cmr-took"=>["40"], "cmr-request-id"=>["5b0c8426-3a23-4025-a4d3-6d1c9024153a"], "vary"=>["Accept-Encoding, User-Agent"], "connection"=>["close"], "server"=>["Jetty(9.2.z-SNAPSHOT)"] })

      record.create_script

      expected = {
        "ShortName" => {
          field_name: "ShortName",
          color:      "red",
          script:     false,
          opinion:    false,
          feedback:   false
        },
        "LongName" => {
          field_name: "LongName",
          color:      "green",
          script:     false,
          opinion:    false,
          feedback:   false
        },
        "VersionId" => {
          field_name: "VersionId",
          color:      "white",
          script:     false,
          opinion:    true,
          feedback:   false
        }
      }
      assert_equal(expected, record.bubble_map)
    end
  end

  describe "color_coding_complete? && has_enough_reviews" do
    it "catches incomplete record reviews" do
      record = records(:first)
      assert_not(record.color_coding_complete?)
      assert_not(record.has_enough_reviews?)

      #testing again with only one color missing
      color_codes = record.get_colors
      color_codes.each_with_index do |(key, value), indexer|
        if indexer == 0
          color_codes[key] = "white"
        else
          color_codes[key] = "green"
        end
      end
      record.update_colors(color_codes)
      assert_not(record.color_coding_complete?)

      #testing again with 1 review, 2 needed
      first_review = record.add_review(1)
      first_review.mark_complete
      assert_not(record.has_enough_reviews?)

      opinion_values = record.get_opinions
      opinion_values["ShortName"] = true
      record.update_opinions(opinion_values)
      assert_not(record.no_second_opinions?)
    end

    it "accepts complete reviews" do
      record = Record.find_by id: 1
      color_codes = record.color_codes
      color_codes.each do |key, value|
        color_codes[key] = "yellow"
      end

      record.update_colors(color_codes)
      #need to reload so the related recordData objects are updated.
      record.reload
      assert_equal(record.color_coding_complete?, true)


      first_review = record.add_review(1)
      first_review.mark_complete
      second_review = record.add_review(2)
      second_review.mark_complete
      assert_equal(record.has_enough_reviews?, true)

      opinion_values = record.get_opinions
      opinion_values["VersionId"] = false
      record.update_opinions(opinion_values)
      record.reload
      assert_equal(record.no_second_opinions?, true)
    end
  end

  describe "close" do

    it "closes a record and sets the closed at date" do
      record = records(:in_daac_review)
      record.close

      assert_equal(record.closed?, true)
      #testing that the time is not null and within range
      assert_equal((record.closed_date && (record.closed_date < DateTime.now) && (record.closed_date > (DateTime.now - 5000))), true)
      record.closed_date = "Tue, 28 Feb 2017 16:25:04 UTC +00:00"
      record.save
      record.reload
      assert_equal(record.formatted_closed_date, "02/28/2017 at 11:25AM")
    end

  end

  describe "evaluate_script" do
    it "returns results of the automated collection_script" do
      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/concepts/C1000000020-LANCEAMSR2.echo10").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: DEPENDENT_COLLECTION, headers: {})

      record = records(:first)
      raw_data = JSON.parse("{\"ShortName\":\"CIESIN_SEDAC_NRMI_NRPCHI15\",\"VersionId\":\"2015.00\",\"InsertTime\":\"2016-11-02T00:00:00.000Z\",\"LastUpdate\":\"2016-11-02T00:00:00.000Z\",\"LongName\":\"Natural Resource Protection and Child Health Indicators, 2015 Release\",\"DataSetId\":\"Natural Resource Protection and Child Health Indicators, 2015 Release\",\"Description\":\"The Natural Resource Protection and Child Health Indicators, 2015 Release, are produced in support of the U.S. Millennium Challenge Corporation as selection criteria for funding eligibility. These indicators are successors to the Natural Resource Management Index (NRMI), which was produced from 2006 to 2011 and was based on the same underlying data. Like the NRMI, the Natural Resource Protection Indicator (NRPI) and Child Health Indicator (CHI) are based on proximity-to-target scores ranging from 0 to 100 (at target). The NRPI covers 221 countries and is calculated based on the weighted average percentage of biomes under protected status. The CHI is a composite index for 188 countries derived from the average of three proximity-to-target scores for access to improved sanitation, access to improved water, and child mortality. The 2015 release includes a consistent time series of NRPIs and CHIs for 2010 to 2015.\",\"CollectionDataType\":\"SCIENCE_QUALITY\",\"Orderable\":\"true\",\"Visible\":\"true\",\"RevisionDate\":\"2016-11-02T00:00:00.000Z\",\"ArchiveCenter\":\"SEDAC\",\"CollectionState\":\"Completed\",\"SpatialKeywords\":{\"Keyword\":[\"AFRICA\",\"ALGERIA\",\"ASIA\",\"AUSTRALIA\",\"BHUTAN\",\"BOTSWANA\",\"BURMA\",\"CAMBODIA\",\"CAMEROON\",\"CANADA\",\"CAPE VERDE\",\"CAYMAN ISLANDS\",\"CENTRAL AFRICAN REPUBLIC\",\"CHAD\",\"CHILE\",\"CHINA\",\"COLOMBIA\",\"COMOROS\",\"CONGO\",\"CONGO, DEMOCRATIC REPUBLIC\",\"COOK ISLANDS\",\"COSTA RICA\",\"COTE D'IVOIRE\",\"CROATIA\",\"CUBA\",\"CURACAO\",\"CYPRUS\",\"CZECH REPUBLIC\",\"DENMARK\",\"DJIBOUTI\",\"DOMINICA\",\"DOMINICAN REPUBLIC\",\"ECUADOR\",\"EGYPT\",\"EL SALVADOR\",\"EQUATORIAL\",\"EQUATORIAL GUINEA\",\"ERITREA\",\"ESTONIA\",\"ETHIOPIA\",\"EUROPE\",\"FAEROE ISLANDS\",\"FALKLAND ISLANDS\",\"FIJI\",\"FINLAND\",\"FRANCE\",\"FRENCH GUIANA\",\"FRENCH POLYNESIA\",\"GABON\",\"GAMBIA\",\"GEORGIA\",\"GERMANY\",\"GHANA\",\"GIBRALTAR\",\"GLOBAL\",\"GREECE\",\"GREENLAND\",\"GRENADA\",\"GUADELOUPE\",\"GUAM\",\"GUATEMALA\",\"GUINEA\",\"GUINEA-BISSAU\",\"GUYANA\",\"HAITI\",\"HONDURAS\",\"HONG KONG\",\"HUNGARY\",\"ICELAND\",\"INDIA\",\"INDONESIA\",\"IRAN\",\"IRAQ\",\"IRELAND\",\"ISLE OF MAN\",\"ISRAEL\",\"ITALY\",\"JAMAICA\",\"JAPAN\",\"JORDAN\",\"KAZAKHSTAN\",\"KENYA\",\"KIRIBATI\",\"KOSOVO\",\"KUWAIT\",\"KYRGYZSTAN\",\"LAO PEOPLE'S DEMOCRATIC REPUBLIC\",\"LATVIA\",\"LEBANON\",\"LESOTHO\",\"LIBERIA\",\"LIBYA\",\"LIECHTENSTEIN\",\"LITHUANIA\",\"LUXEMBOURG\",\"MACAU\",\"MACEDONIA\",\"MADAGASCAR\",\"MALAWI\",\"MALAYSIA\",\"MALDIVES\",\"MALI\",\"MALTA\",\"MARSHALL ISLANDS\",\"MARTINIQUE\",\"MAURITANIA\",\"MAURITIUS\",\"MAYOTTE\",\"MEXICO\",\"MICRONESIA\",\"MID-LATITUDE\",\"MOLDOVA\",\"MONACO\",\"MONGOLIA\",\"MONTENEGRO\",\"MONTSERRAT\",\"MOROCCO\",\"MOZAMBIQUE\",\"NAMIBIA\",\"NAURU\",\"NEPAL\",\"NETHERLANDS\",\"NEW CALEDONIA\",\"NEW ZEALAND\",\"NICARAGUA\",\"NIGER\",\"NIGERIA\",\"NIUE\",\"NORFOLK ISLAND\",\"NORTH AMERICA\",\"NORTH KOREA\",\"NORTHERN MARIANA ISLANDS\",\"NORWAY\",\"OMAN\",\"PAKISTAN\",\"PALAU\",\"PALESTINE\",\"PANAMA\",\"PAPUA NEW GUINEA\",\"PARAGUAY\",\"PERU\",\"PHILIPPINES\",\"PITCAIRN ISLANDS\",\"POLAND\",\"POLAR\",\"PORTUGAL\",\"PUERTO RICO\",\"QATAR\",\"REUNION\",\"ROMANIA\",\"RUSSIAN FEDERATION\",\"RWANDA\",\"SAMOA\",\"SAN MARINO\",\"SAO TOME AND PRINCIPE\",\"SAUDI ARABIA\",\"SENEGAL\",\"SERBIA\",\"SEYCHELLES\",\"SIERRA LEONE\",\"SINGAPORE\",\"SLOVAKIA\",\"SLOVENIA\",\"SOLOMON ISLANDS\",\"SOMALIA\",\"SOUTH AFRICA\",\"SOUTH AMERICA\",\"SOUTH KOREA\",\"SOUTH SUDAN\",\"SPAIN\",\"SRI LANKA\",\"ST HELENA\",\"ST KITTS AND NEVIS\",\"ST LUCIA\",\"ST MAARTEN\",\"ST MARTIN\",\"ST PIERRE AND MIQUELON\",\"ST VINCENT AND THE GRENADINES\",\"SUDAN\",\"SURINAME\",\"SVALBARD AND JAN MAYEN\",\"SWAZILAND\",\"SWEDEN\",\"SWITZERLAND\",\"SYRIAN ARAB REPUBLIC\",\"TAIWAN\",\"TAJIKISTAN\",\"TANZANIA\",\"THAILAND\",\"TIMOR-LESTE\",\"TOGO\",\"TOKELAU\",\"TONGA\",\"TRINIDAD AND TOBAGO\",\"TUNISIA\",\"TURKEY\",\"TURKMENISTAN\",\"TURKS AND CAICOS ISLANDS\",\"TUVALU\",\"UGANDA\",\"UKRAINE\",\"UNITED KINGDOM\",\"UNITED STATES OF AMERICA\",\"URUGUAY\",\"UZBEKISTAN\",\"VANUATU\",\"VENEZUELA\",\"VIETNAM\",\"VIRGIN ISLANDS\",\"WALLIS AND FUTUNA ISLANDS\",\"WESTERN SAHARA\",\"YEMEN\",\"ZAMBIA\",\"ZIMBABWE\"]},\"Temporal\":{\"RangeDateTime\":{\"BeginningDateTime\":\"2010-01-01T00:00:00.000Z\",\"EndingDateTime\":\"2015-12-31T23:59:59.999Z\"}},\"Contacts\":{\"Contact\":[{\"Role\":\"METADATA AUTHOR\",\"OrganizationEmails\":{\"Email\":\"metadata@ciesin.columbia.edu\"},\"ContactPersons\":{\"ContactPerson\":{\"FirstName\":\"unknown\",\"LastName\":\"CIESIN METADATA ADMINISTRATION\"}}},{\"Role\":\"TECHNICAL CONTACT\",\"OrganizationEmails\":{\"Email\":\"ciesin.info@ciesin.columbia.edu\"},\"ContactPersons\":{\"ContactPerson\":{\"FirstName\":\"unknown\",\"LastName\":\"SEDAC USER SERVICES\"}}}]},\"ScienceKeywords\":{\"ScienceKeyword\":[{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"BIOSPHERE\",\"TermKeyword\":\"ECOLOGICAL DYNAMICS\",\"VariableLevel1Keyword\":{\"Value\":\"COMMUNITY DYNAMICS\",\"VariableLevel2Keyword\":{\"Value\":\"BIODIVERSITY FUNCTIONS\"}}},{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"BIOSPHERE\",\"TermKeyword\":\"ECOSYSTEMS\",\"VariableLevel1Keyword\":{\"Value\":\"TERRESTRIAL ECOSYSTEMS\",\"VariableLevel2Keyword\":{\"Value\":\"ALPINE/TUNDRA\",\"VariableLevel3Keyword\":\"ALPINE TUNDRA\"}}},{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"BIOSPHERE\",\"TermKeyword\":\"ECOSYSTEMS\",\"VariableLevel1Keyword\":{\"Value\":\"TERRESTRIAL ECOSYSTEMS\",\"VariableLevel2Keyword\":{\"Value\":\"FORESTS\"}}},{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"HUMAN DIMENSIONS\",\"TermKeyword\":\"ENVIRONMENTAL IMPACTS\",\"VariableLevel1Keyword\":{\"Value\":\"CONSERVATION\"}},{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"HUMAN DIMENSIONS\",\"TermKeyword\":\"SUSTAINABILITY\",\"VariableLevel1Keyword\":{\"Value\":\"ENVIRONMENTAL SUSTAINABILITY\"}}]},\"Platforms\":{\"Platform\":{\"ShortName\":\"NOT APPLICABLE\",\"LongName\":null,\"Type\":\"Not applicable\",\"Instruments\":{\"Instrument\":{\"ShortName\":\"NOT APPLICABLE\"}}}},\"Campaigns\":{\"Campaign\":{\"ShortName\":\"NRMI\",\"LongName\":\"Natural Resources Management Index\"}},\"OnlineAccessURLs\":{\"OnlineAccessURL\":{\"URL\":\"http://sedac.ciesin.columbia.edu/data/set/nrmi-natural-resource-protection-child-health-indicators-2015/data-download\",\"URLDescription\":\"Data landing page\"}},\"Spatial\":{\"HorizontalSpatialDomain\":{\"Geometry\":{\"CoordinateSystem\":\"CARTESIAN\",\"BoundingRectangle\":{\"WestBoundingCoordinate\":\"-180\",\"NorthBoundingCoordinate\":\"90\",\"EastBoundingCoordinate\":\"180\",\"SouthBoundingCoordinate\":\"-55\"}}},\"GranuleSpatialRepresentation\":\"CARTESIAN\"}}")

      comment_hash = record.evaluate_script(raw_data)
      comment_hash = sort_by_key(comment_hash)

      #URL is removed to prevent this test fails when it is broken link
      comment_hash.delete("OnlineAccessURLs/OnlineAccessURL/URL")
      comment_hash.delete("OnlineResources/OnlineResource/URL")
      expect_str=%q{{"AdditionalAttributes/AdditionalAttribute/DataType"=>"OK", "AdditionalAttributes/AdditionalAttribute/Value"=>"doi_link_update failed<br>", "ArchiveCenter"=>"<b>Errors:</b><ul><li>Error: The provided data center short name `GHRC` does not comply with the GCMD. </li> </ul><b>Remediation:</b><br>Please submit a request to support@earthdata.nasa.gov to have this instrument added to the GCMD Instrument KMS.", "Campaigns/Campaign/ShortName"=>"OK", "CitationforExternalPublication"=>"<b>Errors:</b><ul><li>Warning: No CitationforExternalPublication is provided.</li> </ul><b>Remediation:</b><br>Please provide a citation for the dataset in the CitationforExternalPublication field.", "CollectionDataType"=>"OK", "Contacts/Contact/Role"=>"<b>Errors:</b><ul><li>Error: `GHRC USER SERVICES` is not a valid Contact Role.</li> </ul><b>Remediation:</b><br>Select a Contact Role from the following list: ['ARCHIVER', 'DISTRIBUTOR', 'PROCESSOR', 'ORIGINATOR'].", "DOI/Explanation"=>"OK", "DataSetId"=>"OK", "Description"=>"OK", "InsertTime"=>"OK", "LastUpdate"=>"OK", "OnlineResources/OnlineResource/MimeType"=>"OK", "OnlineResources/OnlineResource/Type"=>"<b>Errors:</b><ul><li>Error: Online Resource Type `Alternate Data Access` is not consistent with GCMD 'rucontenttype' list.</li> <li>Error: Online Resource Type `Browse` is not consistent with GCMD 'rucontenttype' list.</li> <li>Error: Online Resource Type `Worldview Imagery` is not consistent with GCMD 'rucontenttype' list.</li> <li>Error: Online Resource Type `Homepage` is not consistent with GCMD 'rucontenttype' list.</li> <li>Error: Online Resource Type `Guide` is not consistent with GCMD 'rucontenttype' list.</li> <li>Error: Online Resource Type `DOI` is not consistent with GCMD 'rucontenttype' list.</li> <li>Error: Online Resource Type `Citing GHRC Data` is not consistent with GCMD 'rucontenttype' list.</li> </ul><b>Remediation:</b><br>Please provide a GCMD compliant Online Resource Type.", "Orderable"=>"OK", "Platforms/Platform/Instruments/Instrument/Characteristics/Characteristic/Description"=>"OK", "Platforms/Platform/Instruments/Instrument/Characteristics/Characteristic/Name"=>"OK", "Platforms/Platform/Instruments/Instrument/Characteristics/Characteristic/Unit"=>"OK", "Platforms/Platform/Instruments/Instrument/Characteristics/Characteristic/Value"=>"OK", "Platforms/Platform/Instruments/Instrument/Sensors/Sensor/ShortName"=>"OK", "Platforms/Platform/Instruments/Instrument/ShortName"=>"OK", "Platforms/Platform/LongName"=>"<b>Errors:</b><ul><li>Error: The provided platform long name `GCOM-W1` does not comply with the GCMD.</li> </ul><b>Remediation:</b><br>Please submit a request to support@earthdata.nasa.gov to have this data format added to the GCMD Data Format KMS.", "Platforms/Platform/ShortName"=>"OK", "Platforms/Platform/Type"=>"<b>Errors:</b><ul><li>Error: The provided platform type `SATELLITE` does not comply with the GCMD.</li> </ul><b>Remediation:</b><br>Please submit a request to support@earthdata.nasa.gov to have this platform type added to the GCMD Locations KMS.", "ProcessingLevelId"=>"OK", "ScienceKeywords/ScienceKeyword/CategoryKeyword"=>"OK", "Spatial/GranuleSpatialRepresentation"=>"OK", "Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle"=>"<b>Errors:</b><ul><li>Error: North bounding coordinate should always be larger than South bounding coordinate and East bounding coordinate should always be larger than West bounding coordinate.</li> </ul><b>Remediation:</b><br>Please make sure the coordinate values are correct.", "Spatial/HorizontalSpatialDomain/Geometry/CoordinateSystem"=>"<b>Errors:</b><ul><li>Error: Missing child element(s). Expected is one of ( Point, BoundingRectangle, GPolygon, Line ).</li> </ul>xml_schema failed<br>", "Spatial/HorizontalSpatialDomain/Geometry/Point"=>"<b>Errors:</b><ul><li>Info: No spatial extent is provided.</li> </ul><b>Remediation:</b><br>Please provide a spatial extent in one of the following form: Point, Bounding Rectangle, GPolygon, Line", "Spatial/SpatialCoverageType"=>"OK", "SpatialInfo/HorizontalCoordinateSystem/GeodeticModel/HorizontalDatumName"=>"<b>Errors:</b><ul><li>Info: Horizontal Datum Name is missing.</li> </ul><b>Remediation:</b><br>Please provide a Horizontal Datum Name.", "SpatialInfo/SpatialCoverageType"=>"<b>Errors:</b><ul><li>Info: Spatial Coverage Type is missing.</li> </ul><b>Remediation:</b><br>Please provide a spatial coverage type from the following list: ['HORIZONTAL', 'VERTICAL', 'ORBITAL', 'HORIZONTAL_VERTICAL', 'ORBITAL_VERTICAL', 'HORIZONTAL_ORBITAL', 'HORIZONTAL_VERTICAL_ORBITAL']", "SpatialKeywords/Keyword"=>"OK", "Temporal/EndsAtPresentFlag"=>"<b>Errors:</b><ul><li>Warning: Potential issue with:\n - No EndingDateTime provided; no EndsAtPresentFlag provided for a potentially active collection. \n - CollectionState = ACTIVE; no EndsAtPresentFlag provided for a potentially active collection.</li> </ul><b>Remediation:</b><br>If data collection is ongoing, provide an EndsAtPresentFlag of \\"true\\"", "Temporal/RangeDateTime/BeginningDateTime"=>"OK", "Temporal/SingleDateTime"=>"OK", "UseConstraints"=>"<b>Errors:</b><ul><li>Warning: No license information is provided.</li> </ul><b>Remediation:</b><br>Please provide information about the license applicable to the dataset, preferably as a URL. For EOSDIS records, please providing the following link (unless under different usage terms): https://earthdata.nasa.gov/earth-observation-data/data-use-policy", "Visible"=>"OK"}}
      assert_equal(expect_str, comment_hash.to_s)
    end

    it "returns results of the automated collection_script for dif10" do
      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/concepts/metric1-PODAAC.dif10").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: DIF10_RECORD, headers: {})

      record = records(:metric1)
      comment_hash = record.evaluate_script(nil)
      comment_hash = sort_by_key(comment_hash)

      expect_str=%q{{"Access_Constraints"=>"<b>Errors:</b><ul><li>Error: Character content other than whitespace is not allowed because the content type is 'element-only'.</li> </ul>xml_schema failed<br>", "DIF"=>"OK", "Dataset_Citation/Dataset_Title"=>"OK", "Dataset_Citation/Persistent_Identifier/Explanation"=>"OK", "Dataset_Citation/Persistent_Identifier/Identifier"=>"<b>Errors:</b><ul><li>Error: `https://www.doi.org/doi:10.4225/15/5747A30D1F767` is invalid.</li> </ul><b>Remediation:</b><br>Provide a valid DOI.", "Dataset_Citation/Version"=>"OK", "Dataset_Progress"=>"OK", "Entry_Title"=>"OK", "ISO_Topic_Category"=>"OK", "Location/Location_Category"=>"OK", "Metadata_Dates/Data_Creation"=>"OK", "Metadata_Dates/Data_Last_Revision"=>"OK", "Metadata_Dates/Metadata_Creation"=>"<b>Errors:</b><ul><li>Error: `2004-07-30` does not adhere to the ISO 1601 standard</li> </ul><b>Remediation:</b><br>Make sure the datetime complies with ISO 1601 standard.", "Metadata_Dates/Metadata_Last_Revision"=>"<b>Errors:</b><ul><li>Error: `2017-04-26` does not adhere to the ISO 1601 standard</li> </ul><b>Remediation:</b><br>Make sure the datetime complies with ISO 1601 standard.", "Multimedia_Sample/Description"=>"OK", "Platform/Characteristics/Description"=>"OK", "Platform/Characteristics/Name"=>"OK", "Platform/Characteristics/Unit"=>"OK", "Platform/Characteristics/Value"=>"OK", "Platform/Instrument/Short_Name"=>"<b>Errors:</b><ul><li>Error: The provided instrument short name `Not provided` does not comply with the GCMD.</li> <li>Error: The provided instrument short name `Not provided` does not comply with the GCMD.</li> </ul><b>Remediation:</b><br>Please submit a request to support@earthdata.nasa.gov to have this instrument added to the GCMD Instrument KMS.", "Platform/Type"=>"<b>Errors:</b><ul><li>Error: The provided platform type `Not provided` does not comply with the GCMD.</li> <li>Error: The provided platform type `Not provided` does not comply with the GCMD.</li> <li>Error: The provided platform type `Not provided` does not comply with the GCMD.</li> </ul><b>Remediation:</b><br>Please submit a request to support@earthdata.nasa.gov to have this platform type added to the GCMD Locations KMS.", "Project/Short_Name"=>"OK", "Reference/Persistent_Identifier/Identifier"=>"<b>Errors:</b><ul><li>Error: `https://www.doi.org/doi:10.1016/j.chemosphere.2004.05.042` is invalid.</li> </ul><b>Remediation:</b><br>Provide a valid DOI.", "Related_URL/Description"=>"OK", "Related_URL/Mime_Type"=>"OK", "Spatial_Coverage/Spatial_Info/Horizontal_Coordinate_System/Geodetic_Model/Horizontal_DatumName"=>"<b>Errors:</b><ul><li>Info: Horizontal Datum Name is missing.</li> </ul><b>Remediation:</b><br>Please provide a Horizontal Datum Name.", "Summary/Abstract"=>"OK", "Temporal_Coverage/Ends_At_Present_Flag"=>"OK", "Temporal_Coverage/Range_DateTime/Beginning_Date_Time"=>"OK", "Temporal_Coverage/Range_DateTime/Ending_Date_Time"=>"OK", "Temporal_Coverage/Single_Date_Time"=>"OK", "Use_Constraints/License_URL/Description"=>"OK", "Use_Constraints/License_URL/URL"=>"<b>Errors:</b><ul><li>Warning: No license information is provided.</li> </ul><b>Remediation:</b><br>Please provide information about the license applicable to the dataset, preferably as a URL. For EOSDIS records, please providing the following link (unless under different usage terms): https://earthdata.nasa.gov/earth-observation-data/data-use-policy"}}
      assert_equal(expect_str, comment_hash.to_s)
    end

    it "returns results of the automated granule_script" do
      #manually setting the record as a granule so the evaluate script runs the write python script
      record = Record.find_by id: 5
      raw_data = JSON.parse("{\"ShortName\":\"CIESIN_SEDAC_NRMI_NRPCHI15\",\"VersionId\":\"2015.00\",\"InsertTime\":\"2016-11-02T00:00:00.000Z\",\"LastUpdate\":\"2016-11-02T00:00:00.000Z\",\"LongName\":\"Natural Resource Protection and Child Health Indicators, 2015 Release\",\"DataSetId\":\"Natural Resource Protection and Child Health Indicators, 2015 Release\",\"Description\":\"The Natural Resource Protection and Child Health Indicators, 2015 Release, are produced in support of the U.S. Millennium Challenge Corporation as selection criteria for funding eligibility. These indicators are successors to the Natural Resource Management Index (NRMI), which was produced from 2006 to 2011 and was based on the same underlying data. Like the NRMI, the Natural Resource Protection Indicator (NRPI) and Child Health Indicator (CHI) are based on proximity-to-target scores ranging from 0 to 100 (at target). The NRPI covers 221 countries and is calculated based on the weighted average percentage of biomes under protected status. The CHI is a composite index for 188 countries derived from the average of three proximity-to-target scores for access to improved sanitation, access to improved water, and child mortality. The 2015 release includes a consistent time series of NRPIs and CHIs for 2010 to 2015.\",\"CollectionDataType\":\"SCIENCE_QUALITY\",\"Orderable\":\"true\",\"Visible\":\"true\",\"RevisionDate\":\"2016-11-02T00:00:00.000Z\",\"ArchiveCenter\":\"SEDAC\",\"CollectionState\":\"Completed\",\"SpatialKeywords\":{\"Keyword\":[\"AFRICA\",\"ALGERIA\",\"ASIA\",\"AUSTRALIA\",\"BHUTAN\",\"BOTSWANA\",\"BURMA\",\"CAMBODIA\",\"CAMEROON\",\"CANADA\",\"CAPE VERDE\",\"CAYMAN ISLANDS\",\"CENTRAL AFRICAN REPUBLIC\",\"CHAD\",\"CHILE\",\"CHINA\",\"COLOMBIA\",\"COMOROS\",\"CONGO\",\"CONGO, DEMOCRATIC REPUBLIC\",\"COOK ISLANDS\",\"COSTA RICA\",\"COTE D'IVOIRE\",\"CROATIA\",\"CUBA\",\"CURACAO\",\"CYPRUS\",\"CZECH REPUBLIC\",\"DENMARK\",\"DJIBOUTI\",\"DOMINICA\",\"DOMINICAN REPUBLIC\",\"ECUADOR\",\"EGYPT\",\"EL SALVADOR\",\"EQUATORIAL\",\"EQUATORIAL GUINEA\",\"ERITREA\",\"ESTONIA\",\"ETHIOPIA\",\"EUROPE\",\"FAEROE ISLANDS\",\"FALKLAND ISLANDS\",\"FIJI\",\"FINLAND\",\"FRANCE\",\"FRENCH GUIANA\",\"FRENCH POLYNESIA\",\"GABON\",\"GAMBIA\",\"GEORGIA\",\"GERMANY\",\"GHANA\",\"GIBRALTAR\",\"GLOBAL\",\"GREECE\",\"GREENLAND\",\"GRENADA\",\"GUADELOUPE\",\"GUAM\",\"GUATEMALA\",\"GUINEA\",\"GUINEA-BISSAU\",\"GUYANA\",\"HAITI\",\"HONDURAS\",\"HONG KONG\",\"HUNGARY\",\"ICELAND\",\"INDIA\",\"INDONESIA\",\"IRAN\",\"IRAQ\",\"IRELAND\",\"ISLE OF MAN\",\"ISRAEL\",\"ITALY\",\"JAMAICA\",\"JAPAN\",\"JORDAN\",\"KAZAKHSTAN\",\"KENYA\",\"KIRIBATI\",\"KOSOVO\",\"KUWAIT\",\"KYRGYZSTAN\",\"LAO PEOPLE'S DEMOCRATIC REPUBLIC\",\"LATVIA\",\"LEBANON\",\"LESOTHO\",\"LIBERIA\",\"LIBYA\",\"LIECHTENSTEIN\",\"LITHUANIA\",\"LUXEMBOURG\",\"MACAU\",\"MACEDONIA\",\"MADAGASCAR\",\"MALAWI\",\"MALAYSIA\",\"MALDIVES\",\"MALI\",\"MALTA\",\"MARSHALL ISLANDS\",\"MARTINIQUE\",\"MAURITANIA\",\"MAURITIUS\",\"MAYOTTE\",\"MEXICO\",\"MICRONESIA\",\"MID-LATITUDE\",\"MOLDOVA\",\"MONACO\",\"MONGOLIA\",\"MONTENEGRO\",\"MONTSERRAT\",\"MOROCCO\",\"MOZAMBIQUE\",\"NAMIBIA\",\"NAURU\",\"NEPAL\",\"NETHERLANDS\",\"NEW CALEDONIA\",\"NEW ZEALAND\",\"NICARAGUA\",\"NIGER\",\"NIGERIA\",\"NIUE\",\"NORFOLK ISLAND\",\"NORTH AMERICA\",\"NORTH KOREA\",\"NORTHERN MARIANA ISLANDS\",\"NORWAY\",\"OMAN\",\"PAKISTAN\",\"PALAU\",\"PALESTINE\",\"PANAMA\",\"PAPUA NEW GUINEA\",\"PARAGUAY\",\"PERU\",\"PHILIPPINES\",\"PITCAIRN ISLANDS\",\"POLAND\",\"POLAR\",\"PORTUGAL\",\"PUERTO RICO\",\"QATAR\",\"REUNION\",\"ROMANIA\",\"RUSSIAN FEDERATION\",\"RWANDA\",\"SAMOA\",\"SAN MARINO\",\"SAO TOME AND PRINCIPE\",\"SAUDI ARABIA\",\"SENEGAL\",\"SERBIA\",\"SEYCHELLES\",\"SIERRA LEONE\",\"SINGAPORE\",\"SLOVAKIA\",\"SLOVENIA\",\"SOLOMON ISLANDS\",\"SOMALIA\",\"SOUTH AFRICA\",\"SOUTH AMERICA\",\"SOUTH KOREA\",\"SOUTH SUDAN\",\"SPAIN\",\"SRI LANKA\",\"ST HELENA\",\"ST KITTS AND NEVIS\",\"ST LUCIA\",\"ST MAARTEN\",\"ST MARTIN\",\"ST PIERRE AND MIQUELON\",\"ST VINCENT AND THE GRENADINES\",\"SUDAN\",\"SURINAME\",\"SVALBARD AND JAN MAYEN\",\"SWAZILAND\",\"SWEDEN\",\"SWITZERLAND\",\"SYRIAN ARAB REPUBLIC\",\"TAIWAN\",\"TAJIKISTAN\",\"TANZANIA\",\"THAILAND\",\"TIMOR-LESTE\",\"TOGO\",\"TOKELAU\",\"TONGA\",\"TRINIDAD AND TOBAGO\",\"TUNISIA\",\"TURKEY\",\"TURKMENISTAN\",\"TURKS AND CAICOS ISLANDS\",\"TUVALU\",\"UGANDA\",\"UKRAINE\",\"UNITED KINGDOM\",\"UNITED STATES OF AMERICA\",\"URUGUAY\",\"UZBEKISTAN\",\"VANUATU\",\"VENEZUELA\",\"VIETNAM\",\"VIRGIN ISLANDS\",\"WALLIS AND FUTUNA ISLANDS\",\"WESTERN SAHARA\",\"YEMEN\",\"ZAMBIA\",\"ZIMBABWE\"]},\"Temporal\":{\"RangeDateTime\":{\"BeginningDateTime\":\"2010-01-01T00:00:00.000Z\",\"EndingDateTime\":\"2015-12-31T23:59:59.999Z\"}},\"Contacts\":{\"Contact\":[{\"Role\":\"METADATA AUTHOR\",\"OrganizationEmails\":{\"Email\":\"metadata@ciesin.columbia.edu\"},\"ContactPersons\":{\"ContactPerson\":{\"FirstName\":\"unknown\",\"LastName\":\"CIESIN METADATA ADMINISTRATION\"}}},{\"Role\":\"TECHNICAL CONTACT\",\"OrganizationEmails\":{\"Email\":\"ciesin.info@ciesin.columbia.edu\"},\"ContactPersons\":{\"ContactPerson\":{\"FirstName\":\"unknown\",\"LastName\":\"SEDAC USER SERVICES\"}}}]},\"ScienceKeywords\":{\"ScienceKeyword\":[{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"BIOSPHERE\",\"TermKeyword\":\"ECOLOGICAL DYNAMICS\",\"VariableLevel1Keyword\":{\"Value\":\"COMMUNITY DYNAMICS\",\"VariableLevel2Keyword\":{\"Value\":\"BIODIVERSITY FUNCTIONS\"}}},{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"BIOSPHERE\",\"TermKeyword\":\"ECOSYSTEMS\",\"VariableLevel1Keyword\":{\"Value\":\"TERRESTRIAL ECOSYSTEMS\",\"VariableLevel2Keyword\":{\"Value\":\"ALPINE/TUNDRA\",\"VariableLevel3Keyword\":\"ALPINE TUNDRA\"}}},{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"BIOSPHERE\",\"TermKeyword\":\"ECOSYSTEMS\",\"VariableLevel1Keyword\":{\"Value\":\"TERRESTRIAL ECOSYSTEMS\",\"VariableLevel2Keyword\":{\"Value\":\"FORESTS\"}}},{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"HUMAN DIMENSIONS\",\"TermKeyword\":\"ENVIRONMENTAL IMPACTS\",\"VariableLevel1Keyword\":{\"Value\":\"CONSERVATION\"}},{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"HUMAN DIMENSIONS\",\"TermKeyword\":\"SUSTAINABILITY\",\"VariableLevel1Keyword\":{\"Value\":\"ENVIRONMENTAL SUSTAINABILITY\"}}]},\"Platforms\":{\"Platform\":{\"ShortName\":\"NOT APPLICABLE\",\"LongName\":null,\"Type\":\"Not applicable\",\"Instruments\":{\"Instrument\":{\"ShortName\":\"NOT APPLICABLE\"}}}},\"Campaigns\":{\"Campaign\":{\"ShortName\":\"NRMI\",\"LongName\":\"Natural Resources Management Index\"}},\"OnlineAccessURLs\":{\"OnlineAccessURL\":{\"URL\":\"http://sedac.ciesin.columbia.edu/data/set/nrmi-natural-resource-protection-child-health-indicators-2015/data-download\",\"URLDescription\":\"Data landing page\"}},\"Spatial\":{\"HorizontalSpatialDomain\":{\"Geometry\":{\"CoordinateSystem\":\"CARTESIAN\",\"BoundingRectangle\":{\"WestBoundingCoordinate\":\"-180\",\"NorthBoundingCoordinate\":\"90\",\"EastBoundingCoordinate\":\"180\",\"SouthBoundingCoordinate\":\"-55\"}}},\"GranuleSpatialRepresentation\":\"CARTESIAN\"}}")
      comment_hash = record.evaluate_script(raw_data)
      comment_hash = sort_by_key(comment_hash)

      # #URL is removed to prevent this test fails when it is broken link
      comment_hash.delete("OnlineAccessURLs/OnlineAccessURL/URL")
      comment_hash.delete("OnlineResources/OnlineResource/URL")
      expect_str = %q{{"Campaigns/"=>"OK", "Collection/DataSetId"=>"np - Ensure that the ShortName and VersionId fields are provided.", "Collection/ShortName"=>"np - Ensure the DataSetId field is provided.", "Collection/VersionId"=>"np - Ensure the DataSetId field is provided.", "DataFormat"=>"Recommend providing the data format for the associated granule", "DataGranule/DayNightFlag"=>"np", "DataGranule/ProductionDateTime"=>"np", "DataGranule/SizeMBDataGranule"=>"Granule file size not provided. Recommend providing a value for this field in the metadata", "DeleteTime"=>"np", "InsertTime"=>"InsertTime error.", "LastUpdate"=>"np", "OnlineAccessURLs/OnlineAccessURL/URLDescription"=>"OK - quality check", "OnlineResource/OnlineResource/Description"=>"np", "OnlineResources/OnlineResource/Type"=>"np", "OrbitCalculatedSpatialDomains/OrbitCalculatedSpatialDomain/EquatorCrossingDateTime"=>"np", "Orderable"=>"Note: The Orderable field is being deprecated in UMM.", "Platforms/Platform/Instruments/Instrument/Sensors/Sensor/ShortName"=>"np", "Platforms/Platform/Instruments/Instrument/ShortName"=>"OK- quality check", "Platforms/Platform/ShortName"=>"OK - quality check", "Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle"=>"OK - quality check, OK - quality check, OK - quality check, OK - quality check, ", "Temporal/RangeDateTime/BeginningDateTime"=>"BeginningDateTime error", "Temporal/RangeDateTime/EndingDateTime"=>"EndingDateTime error", "Temporal/RangeDateTime/SingleDateTime"=>"np", "Visible"=>"Note: The Visible field is being deprecated in UMM."}}
      assert_equal(expect_str, comment_hash.to_s)
    end

  end

  describe "daac scope" do
    it "will return records for the given DAAC" do
      records = Record.daac("PODAAC")
      assert_equal 15, records.length
    end

    it "will not return records that belong to anoter DAAC" do
      records = Record.daac("FakeDAAC")
      assert records.empty?
    end
  end

  describe "released_to_daac_date" do
    it "updates the record's released_to_daac_date when releasing" do
      record = Record.first
      assert_nil record.released_to_daac_date
      record.update_released_to_daac_date
      assert_in_delta record.released_to_daac_date, Time.zone.now, 10
    end

    it "removes the record's released_to_daac_date when reverting" do
      record = Record.first
      record.released_to_daac_date = Time.zone.now
      assert_not_nil record.released_to_daac_date
      record.remove_released_to_daac_date
      assert_nil record.released_to_daac_date
    end
  end
end
