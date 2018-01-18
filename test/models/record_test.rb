require 'test_helper'

class RecordTest < ActiveSupport::TestCase

  describe "attribute accessor methods" do
    it "returns correct attribute information for a record" do
      record = Record.find_by id: 1
      #had to remove description from yaml, json strings allow characters not allowed in yaml
      assert_equal(record.is_collection?, true)
      assert_equal(record.is_granule?, false)
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

      #stubbing all requests for raw_data
      stub_request(:get, "https://cmr.earthdata.nasa.gov/search/collections.echo10?concept_id=C1000000020-LANCEAMSR2").with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><results><hits>1</hits><took>14</took><result concept-id=\"C1000000020-LANCEAMSR2\" revision-id=\"8\" format=\"application/echo10+xml\">\n<Collection>\n<ShortName>A2_DySno_NRT</ShortName>\n<VersionId>0</VersionId>\n<InsertTime>2015-05-01T13:26:43Z</InsertTime>\n<LastUpdate>2015-09-14T13:26:43Z</LastUpdate>\n<LongName>NRT AMSR2 DAILY L3 GLOBAL SNOW WATER EQUIVALENT EASE-GRIDS</LongName>\n<DataSetId>NRT AMSR2 DAILY L3 GLOBAL SNOW WATER EQUIVALENT EASE-GRIDS V0</DataSetId>\n<Description>The Advanced Microwave Scanning Radiometer 2 (AMSR2) instrument on the Global Change Observation Mission - Water 1 (GCOM-W1) provides global passive microwave measurements of terrestrial, oceanic, and atmospheric parameters for the investigation of global water and energy cycles.  Near real-time (NRT) products are generated within 3 hours of the last observations in the file, by the Land Atmosphere Near real-time Capability for EOS (LANCE) at the AMSR Science Investigator-led Processing System (AMSR SIPS), which is collocated with the Global Hydrology Resource Center (GHRC) DAAC.  The GCOM-W1 AMSR2 Level-3 Snow Water Equivalent (SWE) data set contains snow water equivalent (SWE) data and quality assurance flags mapped to Northern and Southern Hemisphere 25 km Equal-Area Scalable Earth Grids (EASE-Grids).  Data are stored in HDF-EOS5 format and are available via HTTP from the EOSDIS LANCE system at https://lance.nsstc.nasa.gov/amsr2-science/data/level3/daysnow/R00/hdfeos5/.  If data latency is not a primary concern, please consider using science quality products.  Science products are created using the best available ancillary, calibration and ephemeris information.  Science quality products are an internally consistent, well-calibrated record of the Earth's geophysical properties to support science.  The AMSR SIPS plans to start producing initial AMSR2 standard science quality data products in late 2015 and they will be available from the NSIDC DAAC.  Notice: All LANCE AMSR2 data should be used with the understanding that these are preliminary products.  Cross calibration with AMSR-E products has not been performed.  As updates are made to the L1R data set, those changes will be reflected in this higher level product.</Description>\n<CollectionDataType>NEAR_REAL_TIME</CollectionDataType>\n<Orderable>false</Orderable>\n<Visible>true</Visible>\n<ProcessingLevelId>3</ProcessingLevelId>\n<ArchiveCenter>GHRC</ArchiveCenter>\n<CitationForExternalPublication>Tedesco, M., J. Jeyaratnam, and R. Kelly. 2015. NRT AMSR2 Daily L3 Global Snow Water Equivalent EASE-Grids [indicate subset used]. Dataset available online, [https://lance.nsstc.nasa.gov/amsr2-science/data/level3/daysnow/R00/hdfeos5/] from NASA LANCE AMSR2 at the GHRC DAAC Huntsville, Alabama, U.S.A. doi: http://dx.doi.org/10.5067/AMSR2/A2_DySno_NRT</CitationForExternalPublication><Price>0.0</Price><SpatialKeywords>\n<Keyword>GLOBAL</Keyword></SpatialKeywords><TemporalKeywords>\n<Keyword>DAILY</Keyword></TemporalKeywords><Temporal><RangeDateTime>\n<BeginningDateTime>2015-05-01T00:00:00Z</BeginningDateTime></RangeDateTime></Temporal><Contacts><Contact>\n<Role>GHRC USER SERVICES</Role><OrganizationEmails>\n<Email>ghrc-dmg@itsc.uah.edu</Email></OrganizationEmails></Contact></Contacts><ScienceKeywords><ScienceKeyword>\n<CategoryKeyword>EARTH SCIENCE</CategoryKeyword>\n<TopicKeyword>CRYOSPHERE</TopicKeyword>\n<TermKeyword>SNOW/ICE</TermKeyword><VariableLevel1Keyword>\n<Value>SNOW WATER EQUIVALENT</Value></VariableLevel1Keyword></ScienceKeyword><ScienceKeyword>\n<CategoryKeyword>EARTH SCIENCE</CategoryKeyword>\n<TopicKeyword>TERRESTRIAL HYDROSPHERE</TopicKeyword>\n<TermKeyword>SNOW/ICE</TermKeyword><VariableLevel1Keyword>\n<Value>SNOW WATER EQUIVALENT</Value></VariableLevel1Keyword></ScienceKeyword></ScienceKeywords><Platforms><Platform>\n<ShortName>GCOM-W1</ShortName>\n<LongName>GCOM-W1</LongName>\n<Type>SATELLITE</Type><Instruments><Instrument>\n<ShortName>AMSR2</ShortName><Sensors><Sensor>\n<ShortName>AMSR2</ShortName></Sensor></Sensors></Instrument></Instruments></Platform></Platforms>\n<AdditionalAttributes>\n<AdditionalAttribute>\n<Name>identifier_product_doi</Name>\n<DataType>STRING</DataType>\n<Description>product DOI</Description>\n<Value>10.5067/AMSR2/A2_DySno_NRT</Value>\n</AdditionalAttribute>\n<AdditionalAttribute>\n<Name>identifier_product_doi_authority</Name>\n<DataType>STRING</DataType>\n<Description>DOI authority</Description>\n<Value>http://dx.doi.org</Value>\n</AdditionalAttribute>\n</AdditionalAttributes>\n<Campaigns><Campaign>\n<ShortName>LANCE</ShortName></Campaign></Campaigns><OnlineAccessURLs><OnlineAccessURL>\n<URL>https://lance.nsstc.nasa.gov/amsr2-science/data/level3/daysnow/R00/hdfeos5/</URL><URLDescription></URLDescription><MimeType></MimeType></OnlineAccessURL></OnlineAccessURLs><OnlineResources><OnlineResource>\n<URL>https://lance.itsc.uah.edu/amsr2-science/data/level3/daysnow/R00/hdfeos5/</URL><Description></Description>\n<Type>Alternate Data Access</Type></OnlineResource><OnlineResource>\n<URL>https://lance.nsstc.nasa.gov/amsr2-science/browse_png/level3/daysnow/R00/</URL><Description></Description>\n<Type>Browse</Type></OnlineResource><OnlineResource>\n<URL>https://worldview.earthdata.nasa.gov/</URL><Description></Description>\n<Type>Worldview Imagery</Type></OnlineResource><OnlineResource>\n<URL>http://lance.nsstc.nasa.gov/</URL><Description></Description>\n<Type>Homepage</Type></OnlineResource><OnlineResource>\n<URL>http://lance.nsstc.nasa.gov/amsr2-science/doc/LANCE_A2_DySno_NRT_dataset.pdf</URL><Description></Description>\n<Type>Guide</Type></OnlineResource><OnlineResource>\n<URL>http://dx.doi.org/10.5067/AMSR2/A2_DySno_NRT</URL><Description></Description>\n<Type>DOI</Type></OnlineResource><OnlineResource>\n<URL>http://ghrc.nsstc.nasa.gov/uso/citation.html</URL><Description></Description>\n<Type>Citing GHRC Data</Type></OnlineResource></OnlineResources><AssociatedDIFs><DIF>\n<EntryId>A2_DySno_NRT</EntryId></DIF></AssociatedDIFs><Spatial><SpatialCoverageType>Horizontal</SpatialCoverageType><HorizontalSpatialDomain><Geometry>\n<CoordinateSystem>CARTESIAN</CoordinateSystem><BoundingRectangle>\n<WestBoundingCoordinate>-180</WestBoundingCoordinate>\n<NorthBoundingCoordinate>90</NorthBoundingCoordinate>\n<EastBoundingCoordinate>180</EastBoundingCoordinate>\n<SouthBoundingCoordinate>-90</SouthBoundingCoordinate></BoundingRectangle></Geometry></HorizontalSpatialDomain>\n<GranuleSpatialRepresentation>CARTESIAN</GranuleSpatialRepresentation></Spatial>\n<MetadataStandardName>ECHO</MetadataStandardName>\n<MetadataStandardVersion>10</MetadataStandardVersion>\n</Collection></result></results>", :headers => {"date"=>["Tue, 21 Feb 2017 16:02:46 GMT"], "content-type"=>["application/echo10+xml; charset=utf-8"], "access-control-expose-headers"=>["CMR-Hits, CMR-Request-Id"], "access-control-allow-origin"=>["*"], "cmr-hits"=>["10554"], "cmr-took"=>["40"], "cmr-request-id"=>["5b0c8426-3a23-4025-a4d3-6d1c9024153a"], "vary"=>["Accept-Encoding, User-Agent"], "connection"=>["close"], "server"=>["Jetty(9.2.z-SNAPSHOT)"]})

      record.create_script
      script_values = record.script_values
      assert_equal(script_values, {"LongName"=>"ok", "ShortName"=>"ok", "VersionId"=>"ok"})
    end
  end

  describe "bubble_map" do
    it "returns correct bubble map" do
      record = Record.find_by id: 1

      #stubbing all requests for raw_data
      stub_request(:get, "https://cmr.earthdata.nasa.gov/search/collections.echo10?concept_id=C1000000020-LANCEAMSR2").with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><results><hits>1</hits><took>14</took><result concept-id=\"C1000000020-LANCEAMSR2\" revision-id=\"8\" format=\"application/echo10+xml\">\n<Collection>\n<ShortName>A2_DySno_NRT</ShortName>\n<VersionId>0</VersionId>\n<InsertTime>2015-05-01T13:26:43Z</InsertTime>\n<LastUpdate>2015-09-14T13:26:43Z</LastUpdate>\n<LongName>NRT AMSR2 DAILY L3 GLOBAL SNOW WATER EQUIVALENT EASE-GRIDS</LongName>\n<DataSetId>NRT AMSR2 DAILY L3 GLOBAL SNOW WATER EQUIVALENT EASE-GRIDS V0</DataSetId>\n<Description>The Advanced Microwave Scanning Radiometer 2 (AMSR2) instrument on the Global Change Observation Mission - Water 1 (GCOM-W1) provides global passive microwave measurements of terrestrial, oceanic, and atmospheric parameters for the investigation of global water and energy cycles.  Near real-time (NRT) products are generated within 3 hours of the last observations in the file, by the Land Atmosphere Near real-time Capability for EOS (LANCE) at the AMSR Science Investigator-led Processing System (AMSR SIPS), which is collocated with the Global Hydrology Resource Center (GHRC) DAAC.  The GCOM-W1 AMSR2 Level-3 Snow Water Equivalent (SWE) data set contains snow water equivalent (SWE) data and quality assurance flags mapped to Northern and Southern Hemisphere 25 km Equal-Area Scalable Earth Grids (EASE-Grids).  Data are stored in HDF-EOS5 format and are available via HTTP from the EOSDIS LANCE system at https://lance.nsstc.nasa.gov/amsr2-science/data/level3/daysnow/R00/hdfeos5/.  If data latency is not a primary concern, please consider using science quality products.  Science products are created using the best available ancillary, calibration and ephemeris information.  Science quality products are an internally consistent, well-calibrated record of the Earth's geophysical properties to support science.  The AMSR SIPS plans to start producing initial AMSR2 standard science quality data products in late 2015 and they will be available from the NSIDC DAAC.  Notice: All LANCE AMSR2 data should be used with the understanding that these are preliminary products.  Cross calibration with AMSR-E products has not been performed.  As updates are made to the L1R data set, those changes will be reflected in this higher level product.</Description>\n<CollectionDataType>NEAR_REAL_TIME</CollectionDataType>\n<Orderable>false</Orderable>\n<Visible>true</Visible>\n<ProcessingLevelId>3</ProcessingLevelId>\n<ArchiveCenter>GHRC</ArchiveCenter>\n<CitationForExternalPublication>Tedesco, M., J. Jeyaratnam, and R. Kelly. 2015. NRT AMSR2 Daily L3 Global Snow Water Equivalent EASE-Grids [indicate subset used]. Dataset available online, [https://lance.nsstc.nasa.gov/amsr2-science/data/level3/daysnow/R00/hdfeos5/] from NASA LANCE AMSR2 at the GHRC DAAC Huntsville, Alabama, U.S.A. doi: http://dx.doi.org/10.5067/AMSR2/A2_DySno_NRT</CitationForExternalPublication><Price>0.0</Price><SpatialKeywords>\n<Keyword>GLOBAL</Keyword></SpatialKeywords><TemporalKeywords>\n<Keyword>DAILY</Keyword></TemporalKeywords><Temporal><RangeDateTime>\n<BeginningDateTime>2015-05-01T00:00:00Z</BeginningDateTime></RangeDateTime></Temporal><Contacts><Contact>\n<Role>GHRC USER SERVICES</Role><OrganizationEmails>\n<Email>ghrc-dmg@itsc.uah.edu</Email></OrganizationEmails></Contact></Contacts><ScienceKeywords><ScienceKeyword>\n<CategoryKeyword>EARTH SCIENCE</CategoryKeyword>\n<TopicKeyword>CRYOSPHERE</TopicKeyword>\n<TermKeyword>SNOW/ICE</TermKeyword><VariableLevel1Keyword>\n<Value>SNOW WATER EQUIVALENT</Value></VariableLevel1Keyword></ScienceKeyword><ScienceKeyword>\n<CategoryKeyword>EARTH SCIENCE</CategoryKeyword>\n<TopicKeyword>TERRESTRIAL HYDROSPHERE</TopicKeyword>\n<TermKeyword>SNOW/ICE</TermKeyword><VariableLevel1Keyword>\n<Value>SNOW WATER EQUIVALENT</Value></VariableLevel1Keyword></ScienceKeyword></ScienceKeywords><Platforms><Platform>\n<ShortName>GCOM-W1</ShortName>\n<LongName>GCOM-W1</LongName>\n<Type>SATELLITE</Type><Instruments><Instrument>\n<ShortName>AMSR2</ShortName><Sensors><Sensor>\n<ShortName>AMSR2</ShortName></Sensor></Sensors></Instrument></Instruments></Platform></Platforms>\n<AdditionalAttributes>\n<AdditionalAttribute>\n<Name>identifier_product_doi</Name>\n<DataType>STRING</DataType>\n<Description>product DOI</Description>\n<Value>10.5067/AMSR2/A2_DySno_NRT</Value>\n</AdditionalAttribute>\n<AdditionalAttribute>\n<Name>identifier_product_doi_authority</Name>\n<DataType>STRING</DataType>\n<Description>DOI authority</Description>\n<Value>http://dx.doi.org</Value>\n</AdditionalAttribute>\n</AdditionalAttributes>\n<Campaigns><Campaign>\n<ShortName>LANCE</ShortName></Campaign></Campaigns><OnlineAccessURLs><OnlineAccessURL>\n<URL>https://lance.nsstc.nasa.gov/amsr2-science/data/level3/daysnow/R00/hdfeos5/</URL><URLDescription></URLDescription><MimeType></MimeType></OnlineAccessURL></OnlineAccessURLs><OnlineResources><OnlineResource>\n<URL>https://lance.itsc.uah.edu/amsr2-science/data/level3/daysnow/R00/hdfeos5/</URL><Description></Description>\n<Type>Alternate Data Access</Type></OnlineResource><OnlineResource>\n<URL>https://lance.nsstc.nasa.gov/amsr2-science/browse_png/level3/daysnow/R00/</URL><Description></Description>\n<Type>Browse</Type></OnlineResource><OnlineResource>\n<URL>https://worldview.earthdata.nasa.gov/</URL><Description></Description>\n<Type>Worldview Imagery</Type></OnlineResource><OnlineResource>\n<URL>http://lance.nsstc.nasa.gov/</URL><Description></Description>\n<Type>Homepage</Type></OnlineResource><OnlineResource>\n<URL>http://lance.nsstc.nasa.gov/amsr2-science/doc/LANCE_A2_DySno_NRT_dataset.pdf</URL><Description></Description>\n<Type>Guide</Type></OnlineResource><OnlineResource>\n<URL>http://dx.doi.org/10.5067/AMSR2/A2_DySno_NRT</URL><Description></Description>\n<Type>DOI</Type></OnlineResource><OnlineResource>\n<URL>http://ghrc.nsstc.nasa.gov/uso/citation.html</URL><Description></Description>\n<Type>Citing GHRC Data</Type></OnlineResource></OnlineResources><AssociatedDIFs><DIF>\n<EntryId>A2_DySno_NRT</EntryId></DIF></AssociatedDIFs><Spatial><SpatialCoverageType>Horizontal</SpatialCoverageType><HorizontalSpatialDomain><Geometry>\n<CoordinateSystem>CARTESIAN</CoordinateSystem><BoundingRectangle>\n<WestBoundingCoordinate>-180</WestBoundingCoordinate>\n<NorthBoundingCoordinate>90</NorthBoundingCoordinate>\n<EastBoundingCoordinate>180</EastBoundingCoordinate>\n<SouthBoundingCoordinate>-90</SouthBoundingCoordinate></BoundingRectangle></Geometry></HorizontalSpatialDomain>\n<GranuleSpatialRepresentation>CARTESIAN</GranuleSpatialRepresentation></Spatial>\n<MetadataStandardName>ECHO</MetadataStandardName>\n<MetadataStandardVersion>10</MetadataStandardVersion>\n</Collection></result></results>", :headers => {"date"=>["Tue, 21 Feb 2017 16:02:46 GMT"], "content-type"=>["application/echo10+xml; charset=utf-8"], "access-control-expose-headers"=>["CMR-Hits, CMR-Request-Id"], "access-control-allow-origin"=>["*"], "cmr-hits"=>["10554"], "cmr-took"=>["40"], "cmr-request-id"=>["5b0c8426-3a23-4025-a4d3-6d1c9024153a"], "vary"=>["Accept-Encoding, User-Agent"], "connection"=>["close"], "server"=>["Jetty(9.2.z-SNAPSHOT)"]})

      record.create_script
      assert_equal(record.bubble_map, {"ShortName"=>{:field_name=>"ShortName", :color=>"green", :script=>false, :opinion=>false}, "LongName"=>{:field_name=>"LongName", :color=>"green", :script=>false, :opinion=>false}, "VersionId"=>{:field_name=>"VersionId", :color=>"white", :script=>false, :opinion=>true}})
    end
  end

  describe "color_coding_complete? && has_enough_reviews" do
    it "catches incomplete record reviews" do
      record = Record.find_by id: 1
      assert_equal(record.color_coding_complete?, false)
      assert_equal(record.has_enough_reviews?, false)

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
      assert_equal(record.color_coding_complete?, false)

      #testing again with 1 review, 2 needed 
      first_review = record.add_review(1)
      first_review.mark_complete
      assert_equal(record.has_enough_reviews?, false)

      opinion_values = record.get_opinions
      opinion_values["ShortName"] = true
      record.update_opinions(opinion_values)
      assert_equal(record.no_second_opinions?, false)
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
    it "closes a record" do
      record = Record.find_by id: 1
      record.close

      assert_equal(record.closed, true)
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
      record = Record.find_by id: 1
      raw_data = {"ShortName"=>"CDDIS_DORIS_products_orbit", "VersionId"=>"1", "LongName"=>"Doppler Orbitography by Radiopositioning Integrated on Satellite Orbits Product from NASA CDDIS"}
      comment_hash = record.evaluate_script(raw_data)

      assert_equal(comment_hash.to_s, "{\"Contacts/Contact/Role\"=>\"np\", \"LastUpdate\"=>\"Provide a last update time for this dataset. This is a required field.\", \"ProcessingCenter\"=>\"np\", \"CitationForExternalPublication\"=>\"np\", \"CollectionState\"=>\"np\", \"Description\"=>\"Provide a description for this dataset. This is a required field.\", \"SpatialKeywords/Keyword\"=>\"Recommend providing a spatial keyword from the following keywords list: http://gcmdservices.gsfc.nasa.gov/static/kms/locations/locations.csv\", \"Temporal/SingleDateTime\"=>\"np\", \"ProcessingLevelId\"=>\"Provide a processing level Id for this dataset. This is a required field.\", \"Visible\"=>\"np\", \"VersionId\"=>\"OK\", \"DataFormat\"=>\"Recommend providing the data format(s) for this dataset.\", \"Temporal/SingleDateTime/BeginningDateTime\"=>\"np\", \"InsertTime\"=>\"Provide an insert time for this dataset. This is a required field.\", \"LongName\"=>\"OK\", \"Orderable\"=>\"np\", \"ShortName\"=>\"OK\", \"ArchiveCenter\"=>\"np, , \", \"Temporal/RangeDateTime/EndingDateTime\"=>\"np\", \"DataSetId\"=>\"Provide a Dataset Id for this dataset. This is a required field.\", \"RevisionDate\"=>\"np\"}")
    end

    it "returns results of the automated granule_script" do
      #manually setting the record as a granule so the evaluate script runs the write python script
      record = Record.find_by id: 5
      raw_data = {"Granule"=>{"GranuleUR"=>"doris_campdata_saacorrection_ja1_ja1data355.saa.Z","InsertTime"=>"2012-11-08T13:15:00","LastUpdate"=>"2012-11-08T13:15:00","Collection"=>{"ShortName"=>"CDDIS_DORIS_data_cycle","VersionId"=>"1"},"DataGranule"=>{"SizeMBDataGranule"=>"3150.2294921875","ProducerGranuleId"=>"doris_campdata_saacorrection_ja1_ja1data355.saa.Z","DayNightFlag"=>"BOTH","ProductionDateTime"=>"2012-11-08T13:15:00"},"Temporal"=>{"RangeDateTime"=>{"BeginningDateTime"=>"2010-12-26T00:00:00","EndingDateTime"=>"2011-01-05T23:59:00"}},"Spatial"=>{"HorizontalSpatialDomain"=>{"Geometry"=>{"BoundingRectangle"=>{"WestBoundingCoordinate"=>"-180.0","NorthBoundingCoordinate"=>"90.0","EastBoundingCoordinate"=>"180.0","SouthBoundingCoordinate"=>"-90.0"}}}},"MeasuredParameters"=>{"MeasuredParameter"=>{"ParameterName"=>"DORIS Satellite Range-Rate Observation Data"}},"OnlineAccessURLs"=>{"OnlineAccessURL"=>{"URL"=>"ftp://cddis.gsfc.nasa.gov/pub/doris/campdata/saacorrection/ja1/ja1data355.saa.Z"}},"Orderable"=>"true","DataFormat"=>"DORIS"}}
      comment_hash = record.evaluate_script(raw_data)

      assert_equal(comment_hash.to_s, "{\"OrbitCalculatedSpatialDomains/OrbitCalculatedSpatialDomain/EquatorCrossingDateTime\"=>\"np\", \"Collection/DataSetId\"=>\"np\", \"Campaigns/Campaign/ShortName\"=>\"np\", \"OnlineAccessURLs/OnlineAccessURL/URLDescription\"=>\"Recommend providing a brief URL description\", \"Temporal/RangeDateTime/BeginningDateTime\"=>\"np\", \"OnlineResources/OnlineResource/Type\"=>\"np\", \"Temporal/RangeDateTime/SingleDateTime\"=>\"np\", \"OnlineAccessURLs/OnlineAccessURL/URL\"=>\"No Online Access URL is provided\", \"Orderable\"=>\"np\", \"OnlineResources/OnlineResource/Description\"=>\"Recommend providing descriptions for all Online Resource URLs.\", \"Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle\"=>\"np, np, np, np\", \"OnlineResources/OnlineResource/URL\"=>\"np\", \"DataGranule/SizeMBDataGranule\"=>\"Granule file size not provided. Recommend providing a value for this field in the metadata\", \"DeleteTime\"=>\"np\", \"Platforms/Platform\"=>\"np\", \"Platforms/Platform/ShortName\"=>\"np\", \"DataFormat\"=>\"Recommend providing the data format for the associated granule\", \"InsertTime\"=>\"np\", \"Temporal/RangeDateTime/EndingDateTime\"=>\"np\", \"LastUpdate\"=>\"np\", \"DataGranule/ProductionDateTime\"=>\"np\", \"Visible\"=>\"np\"}")
    end
  end

  describe "daac scope" do
    it "will return records for the given DAAC" do
      records = Record.daac("PODAAC")
      assert_equal 4, records.length
    end

    it "will not return records that belong to anoter DAAC" do
      records = Record.daac("FakeDAAC")
      assert records.empty?
    end
  end
end