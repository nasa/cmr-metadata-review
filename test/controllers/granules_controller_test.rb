require 'test_helper'
Dir[Rails.root.join("test/**/*.rb")].each {|f| require f}

class GranulesControllerTest < ActionController::TestCase
  include OmniauthMacros

  describe "DELETE #delete" do
    it "deletes a selected granule record from a collection" do
      user = User.find_by role: "admin"
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      user = User.find_by role: "admin"
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      collection = Collection.find(1)
      granule = collection.granules.first
      record  = granule.records.find(16)
      no_granules_before = granule.records.count
      delete :destroy, id: granule.id, record_id: record.id
      no_granules_after = granule.records.count
      assert_equal no_granules_after, (no_granules_before - 1)

      assert_equal "Granule has been deleted.", flash[:notice]
    end
  end

  describe "POST #create" do
    it "creates a new random granule for a collection" do

      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/granules.echo10?concept_id=C1000000020-LANCEAMSR2&page_num=1&page_size=10").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>1</hits><took>17</took><result concept-id="G1581545525-LANCEAMSR2" collection-concept-id="C1000000020-LANCEAMSR2" revision-id="15" format="application/echo10+xml">
    <Granule>
      <GranuleUR>AMSR_2_L3_DailySnow_P00_20190102.he5</GranuleUR>
      <InsertTime>2019-01-03T02:14:37Z</InsertTime>
      <LastUpdate>2019-01-03T02:14:37Z</LastUpdate>
      <DeleteTime>2019-01-16T23:59:59.999Z</DeleteTime>
      <Collection>
        <ShortName>A2_DySno_NRT</ShortName>
        <VersionId>0</VersionId>
      </Collection>
      <DataGranule>
        <DayNightFlag>BOTH</DayNightFlag>
        <ProductionDateTime>2019-01-03T02:14:37Z</ProductionDateTime>
        <LocalVersionId>P00</LocalVersionId>
      </DataGranule>
      <PGEVersionClass>
        <PGEName>DailySnow</PGEName>
        <PGEVersion>00</PGEVersion>
      </PGEVersionClass>
      <Temporal>
        <RangeDateTime>
          <BeginningDateTime>2019-01-02T00:26:32Z</BeginningDateTime>
          <EndingDateTime>2019-01-03T00:14:57Z</EndingDateTime>
        </RangeDateTime>
      </Temporal>
        <Spatial>
          <HorizontalSpatialDomain>
            <Geometry>
              <BoundingRectangle>
                <WestBoundingCoordinate>-180.0</WestBoundingCoordinate>
                <NorthBoundingCoordinate>90.0</NorthBoundingCoordinate>
                <EastBoundingCoordinate>180.0</EastBoundingCoordinate>
                <SouthBoundingCoordinate>-90.0</SouthBoundingCoordinate>
              </BoundingRectangle>
            </Geometry>
          </HorizontalSpatialDomain>
        </Spatial>
      <MeasuredParameters>
        <MeasuredParameter>
          <ParameterName>Snow Water Equivalent</ParameterName>
        </MeasuredParameter>
      </MeasuredParameters>
      <AdditionalAttributes>
        <AdditionalAttribute>
          <Name>identifier_product_doi</Name>
          <Values>
            <Value>10.5067/AMSR2/A2_DySno_NRT</Value>
          </Values>
        </AdditionalAttribute>
        <AdditionalAttribute>
          <Name>identifier_product_doi_authority</Name>
          <Values>
            <Value>http://dx.doi.org</Value>
          </Values>
        </AdditionalAttribute>
      </AdditionalAttributes>
      <InputGranules>
        <InputGranule>(GW1AM2_201901020026_185D_L1SNRTBR_2220220.h5</InputGranule>
      </InputGranules>
      <OnlineAccessURLs>
        <OnlineAccessURL>
          <URL>https://lance.nsstc.nasa.gov/amsr2-science/data/level3/daysnow/R00/hdfeos5/AMSR_2_L3_DailySnow_P00_20190102.he5</URL>
          <URLDescription>Online access to AMSR-2 Near-Real-Time LANCE Products (primary)</URLDescription>
        </OnlineAccessURL>
        <OnlineAccessURL>
          <URL>https://lance.itsc.uah.edu/amsr2-science/data/level3/daysnow/R00/hdfeos5/AMSR_2_L3_DailySnow_P00_20190102.he5</URL>
          <URLDescription>Online access to AMSR-2 Near-Real-Time LANCE Products (backup)</URLDescription>
        </OnlineAccessURL>
      </OnlineAccessURLs>
      <OnlineResources>
        <OnlineResource>
          <URL>http://dx.doi.org/10.5067/AMSR2/A2_DySno_NRT</URL>
          <Type>Data Object Identifier</Type>
        </OnlineResource>
      </OnlineResources>
      <Orderable>true</Orderable>
      <DataFormat>HDF-EOS 5</DataFormat>
    </Granule></result></results>', headers: {})



      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/granules.echo10?concept_id=G1581545525-LANCEAMSR2").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>1</hits><took>29</took><result concept-id="G1581545525-LANCEAMSR2" collection-concept-id="C1000000020-LANCEAMSR2" revision-id="15" format="application/echo10+xml">
    <Granule>
      <GranuleUR>AMSR_2_L3_DailySnow_P00_20190102.he5</GranuleUR>
      <InsertTime>2019-01-03T02:14:37Z</InsertTime>
      <LastUpdate>2019-01-03T02:14:37Z</LastUpdate>
      <DeleteTime>2019-01-16T23:59:59.999Z</DeleteTime>
      <Collection>
        <ShortName>A2_DySno_NRT</ShortName>
        <VersionId>0</VersionId>
      </Collection>
      <DataGranule>
        <DayNightFlag>BOTH</DayNightFlag>
        <ProductionDateTime>2019-01-03T02:14:37Z</ProductionDateTime>
        <LocalVersionId>P00</LocalVersionId>
      </DataGranule>
      <PGEVersionClass>
        <PGEName>DailySnow</PGEName>
        <PGEVersion>00</PGEVersion>
      </PGEVersionClass>
      <Temporal>
        <RangeDateTime>
          <BeginningDateTime>2019-01-02T00:26:32Z</BeginningDateTime>
          <EndingDateTime>2019-01-03T00:14:57Z</EndingDateTime>
        </RangeDateTime>
      </Temporal>
        <Spatial>
          <HorizontalSpatialDomain>
            <Geometry>
              <BoundingRectangle>
                <WestBoundingCoordinate>-180.0</WestBoundingCoordinate>
                <NorthBoundingCoordinate>90.0</NorthBoundingCoordinate>
                <EastBoundingCoordinate>180.0</EastBoundingCoordinate>
                <SouthBoundingCoordinate>-90.0</SouthBoundingCoordinate>
              </BoundingRectangle>
            </Geometry>
          </HorizontalSpatialDomain>
        </Spatial>
      <MeasuredParameters>
        <MeasuredParameter>
          <ParameterName>Snow Water Equivalent</ParameterName>
        </MeasuredParameter>
      </MeasuredParameters>
      <AdditionalAttributes>
        <AdditionalAttribute>
          <Name>identifier_product_doi</Name>
          <Values>
            <Value>10.5067/AMSR2/A2_DySno_NRT</Value>
          </Values>
        </AdditionalAttribute>
        <AdditionalAttribute>
          <Name>identifier_product_doi_authority</Name>
          <Values>
            <Value>http://dx.doi.org</Value>
          </Values>
        </AdditionalAttribute>
      </AdditionalAttributes>
      <InputGranules>
        <InputGranule>(GW1AM2_201901020026_185D_L1SNRTBR_2220220.h5</InputGranule>
      </InputGranules>
      <OnlineAccessURLs>
        <OnlineAccessURL>
          <URL>https://lance.nsstc.nasa.gov/amsr2-science/data/level3/daysnow/R00/hdfeos5/AMSR_2_L3_DailySnow_P00_20190102.he5</URL>
          <URLDescription>Online access to AMSR-2 Near-Real-Time LANCE Products (primary)</URLDescription>
        </OnlineAccessURL>
        <OnlineAccessURL>
          <URL>https://lance.itsc.uah.edu/amsr2-science/data/level3/daysnow/R00/hdfeos5/AMSR_2_L3_DailySnow_P00_20190102.he5</URL>
          <URLDescription>Online access to AMSR-2 Near-Real-Time LANCE Products (backup)</URLDescription>
        </OnlineAccessURL>
      </OnlineAccessURLs>
      <OnlineResources>
        <OnlineResource>
          <URL>http://dx.doi.org/10.5067/AMSR2/A2_DySno_NRT</URL>
          <Type>Data Object Identifier</Type>
        </OnlineResource>
      </OnlineResources>
      <Orderable>true</Orderable>
      <DataFormat>HDF-EOS 5</DataFormat>
    </Granule></result></results>', headers: {})

      user = User.find_by role: "admin"
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      collection = Collection.find(1)
      no_granules_before = collection.granules.count
      post :create, id: collection.id
      no_granules_after = collection.granules.count
      assert_equal no_granules_after, (no_granules_before + 1)
      assert_equal "A new random granule has been added for this collection", flash[:notice]
    end
  end

  describe "POST #pull_latest" do
    it "pulls in the latest revision of a granule for a collection." do





      stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/granules.echo10?concept_id=G309210-GHRC").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>1</hits><took>29</took><result concept-id="G309210-GHRC" collection-concept-id="C1000000020-LANCEAMSR2" revision-id="15" format="application/echo10+xml">
    <Granule>
      <GranuleUR>AMSR_2_L3_DailySnow_P00_20190102.he5</GranuleUR>
      <InsertTime>2019-01-03T02:14:37Z</InsertTime>
      <LastUpdate>2019-01-03T02:14:37Z</LastUpdate>
      <DeleteTime>2019-01-16T23:59:59.999Z</DeleteTime>
      <Collection>
        <ShortName>A2_DySno_NRT</ShortName>
        <VersionId>0</VersionId>
      </Collection>
      <DataGranule>
        <DayNightFlag>BOTH</DayNightFlag>
        <ProductionDateTime>2019-01-03T02:14:37Z</ProductionDateTime>
        <LocalVersionId>P00</LocalVersionId>
      </DataGranule>
      <PGEVersionClass>
        <PGEName>DailySnow</PGEName>
        <PGEVersion>00</PGEVersion>
      </PGEVersionClass>
      <Temporal>
        <RangeDateTime>
          <BeginningDateTime>2019-01-02T00:26:32Z</BeginningDateTime>
          <EndingDateTime>2019-01-03T00:14:57Z</EndingDateTime>
        </RangeDateTime>
      </Temporal>
        <Spatial>
          <HorizontalSpatialDomain>
            <Geometry>
              <BoundingRectangle>
                <WestBoundingCoordinate>-180.0</WestBoundingCoordinate>
                <NorthBoundingCoordinate>90.0</NorthBoundingCoordinate>
                <EastBoundingCoordinate>180.0</EastBoundingCoordinate>
                <SouthBoundingCoordinate>-90.0</SouthBoundingCoordinate>
              </BoundingRectangle>
            </Geometry>
          </HorizontalSpatialDomain>
        </Spatial>
      <MeasuredParameters>
        <MeasuredParameter>
          <ParameterName>Snow Water Equivalent</ParameterName>
        </MeasuredParameter>
      </MeasuredParameters>
      <AdditionalAttributes>
        <AdditionalAttribute>
          <Name>identifier_product_doi</Name>
          <Values>
            <Value>10.5067/AMSR2/A2_DySno_NRT</Value>
          </Values>
        </AdditionalAttribute>
        <AdditionalAttribute>
          <Name>identifier_product_doi_authority</Name>
          <Values>
            <Value>http://dx.doi.org</Value>
          </Values>
        </AdditionalAttribute>
      </AdditionalAttributes>
      <InputGranules>
        <InputGranule>(GW1AM2_201901020026_185D_L1SNRTBR_2220220.h5</InputGranule>
      </InputGranules>
      <OnlineAccessURLs>
        <OnlineAccessURL>
          <URL>https://lance.nsstc.nasa.gov/amsr2-science/data/level3/daysnow/R00/hdfeos5/AMSR_2_L3_DailySnow_P00_20190102.he5</URL>
          <URLDescription>Online access to AMSR-2 Near-Real-Time LANCE Products (primary)</URLDescription>
        </OnlineAccessURL>
        <OnlineAccessURL>
          <URL>https://lance.itsc.uah.edu/amsr2-science/data/level3/daysnow/R00/hdfeos5/AMSR_2_L3_DailySnow_P00_20190102.he5</URL>
          <URLDescription>Online access to AMSR-2 Near-Real-Time LANCE Products (backup)</URLDescription>
        </OnlineAccessURL>
      </OnlineAccessURLs>
      <OnlineResources>
        <OnlineResource>
          <URL>http://dx.doi.org/10.5067/AMSR2/A2_DySno_NRT</URL>
          <Type>Data Object Identifier</Type>
        </OnlineResource>
      </OnlineResources>
      <Orderable>true</Orderable>
      <DataFormat>HDF-EOS 5</DataFormat>
    </Granule></result></results>', headers: {})


      user = User.find_by role: "admin"
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      granule = Granule.first
      no_granules_before = granule.records.count
      post :pull_latest, id: granule.id
      granule = Granule.first

      no_granules_after = granule.records.count

      assert_equal no_granules_after, (no_granules_before + 1)
      assert_equal "A new granule revision has been added for this collection.", flash[:notice]

    end
  end

  describe "DELETE #replace" do
    it "prevents DAAC curators from replacing the Granule" do
      user = User.find_by role: "daac_curator"
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      granule = Granule.first
      record  = granule.records.find(5)

      delete :replace, id: granule.id, record_id: record.id

      assert_redirected_to general_home_path
      assert_equal "You are not authorized to access this page.", flash[:alert]
    end


    # Removed this test until a better workflow is designed, right now you can't reopen a record, to allow you to
    # ingest it.
    #
    # it "prevents replacement on Granules in review" do
    #   user = User.find_by role: "admin"
    #   sign_in(user)
    #
    #   granule = Granule.first
    #   record  = granule.records.find(5)
    #   collection = granule.collection
    #
    #   delete :replace, id: granule.id, record_id: record.id
    #
    #   assert_redirected_to collection_path(id: 1, record_id: collection.records.first.id)
    #   assert_equal "This granule is in review, and can no longer be changed to a different granule", flash[:alert]
    # end

    it "will delete and replace the granule" do
      user = User.find_by role: "admin"
      sign_in(user)
      stub_urs_access(user.uid, user.access_token, user.refresh_token)

      granule = Granule.first
      record  = granule.records.find(16)
      collection = granule.collection

      Granule.any_instance.expects(:destroy)
      Collection.any_instance.expects(:add_granule)

      delete :replace, id: granule.id, record_id: record.id

      assert_redirected_to collection_path(id: 1, record_id: collection.records.first.id)
      assert_equal "A new granule has been selected for this collection", flash[:notice]
    end
  end
end
