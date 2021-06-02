require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class CanRefreshAClosedRecordTest < Capybara::Rails::TestCase
  include Helpers::UserHelpers
  include Helpers::ReviewsHelper
  include Helpers::HomeHelper
  include Helpers::CollectionsHelper

  before do
    OmniAuth.config.test_mode = true
    mock_login(role: 'admin')

    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=G309210-GHRC")
        .with(
            headers: {'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept' => '*/*', 'User-Agent' => 'Ruby'}
        )
        .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>0</hits><took>32</took></results>', headers: {})

    stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/collections.xml?concept_id%5B%5D=metric1-PODAAC")
        .with(
            headers: {
                'Accept' => '*/*',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'User-Agent' => 'Ruby'}
        )
        .to_return(status: 200, body: "<results>
            <hits>1</hits>
            <took>8</took>
            <references>
            <reference>
            <name>
            Waveglider data for the SPURS-1 N. Atlantic field campaign
            </name>
            <id>metric1-PODAAC</id>
            <location>
            https://cmr.earthdata.nasa.gov:443/search/concepts/metric1-PODAAC/4
            </location>
            <revision-id>4</revision-id>
            </reference>
            </references>
            </results>", headers: {}
        )

    stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/collections.atom?concept_id=metric1-PODAAC")
        .with(
            headers: {
                'Accept' => '*/*',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'User-Agent' => 'Ruby'}
        )
        .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><feed xmlns:os="http://a9.com/-/spec/opensearch/1.1/" 
            xmlns:georss="http://www.georss.org/georss/10" xmlns="http://www.w3.org/2005/Atom" xmlns:dc="http://purl.org/dc/elements/1.1/" 
            xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" 
            xmlns:esipdiscovery="http://commons.esipfed.org/ns/discovery/1.2/" xmlns:gml="http://www.opengis.net/gml" esipdiscovery:version="1.2" 
            xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/"><updated>2021-05-28T22:15:47.949Z</updated><id>https://cmr.earthdata.nasa.gov:443/search/collections.atom?concept_id=C1652975935-PODAAC</id><title 
            type="text">ECHO dataset metadata</title><entry><id>C1652975935-PODAAC</id><title type="text">Waveglider data for the SPURS-1 N. 
            Atlantic field campaign</title><summary type="text">The SPURS (Salinity Processes in the Upper Ocean Regional Study) project is an 
            oceanographic process study and associated field program that aim to elucidate key mechanisms responsible for near-surface salinity 
            variations in the oceans. The project involves two field campaigns and a series of cruises in regions of the Atlantic and Pacific Oceans 
            exhibiting salinity extremes.  SPURS employs a suite of state-of-the-art in-situ sampling technologies that, combined with remotely sensed 
            salinity fields from the Aquarius/SAC-D and SMOS satellites, provide a detailed characterization of salinity structure over a continuum of 
            spatio-temporal scales.  The SPURS-1 campaign involved a series of 5 cruises during 2012 - 2013 seeking to characterize the salinity 
            structure and balance in a high salinity, high evaporation, and low rainfall region of the subtropical North Atlantic. It aims to resolve 
            processes responsible for maintaining the subtropical surface salinity maximum in this region and within a 900 x 800-mile square study 
            area centered at 25N, 38W. A Waveglider is an autonomous platform propelled by the conversion of ocean wave energy into forward thrust 
            and employing solar panels to power instrumentation. During SPURS-1, three wavegliders (ASL2, ASL3 and ASL4) were deployed from the Knorr 
            in September 2012, redeployed in April 2013 (ASL22, ASL32 and ASL42) with final recovery in September. Waveglider trajectories followed a 
            square loop or butterfly pattern around the central SPURS mooring.  Sensors included a CTD at the near-surface and another at 6 m depth, 
            a surface current meter, air temperature, atmospheric pressure and wind speed sensors providing continuous  along-track observations.  
            NetCDF waveglider data files here contain hour averaged, georeferenced  trajectory data for those parameters and depths.</summary><updated>2017-04-28T05:01:46.000Z</updated><echo:datasetId>Waveglider data for the SPURS-1 N. 
            Atlantic field campaign</echo:datasetId><echo:shortName>SPURS1_WAVEGLIDER</echo:shortName><echo:versionId>1.0</echo:versionId><echo:originalFormat>UMM_JSON</echo:originalFormat><echo:dataCenter>PODAAC</echo:dataCenter><echo:archiveCenter>NASA/JPL/PODAAC</echo:archiveCenter><echo:organization>NASA/JPL/PODAAC</echo:organization><echo:organization>SPURS 
            Project</echo:organization><echo:processingLevelId>2</echo:processingLevelId><time:start>2012-09-01T00:00:00.000Z</time:start><time:end>2013-03-25T00:00:00.000Z</time:end><link rel="http://esipfed.org/ns/fedsearch/1.1/documentation#" 
            hreflang="en-US" href="http://spurs.jpl.nasa.gov/"></link><link rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" hreflang="en-US" 
            href="https://podaac-tools.jpl.nasa.gov/drive/files/allData/insitu/L2/spurs1/sw/R"></link><link 
            rel="http://esipfed.org/ns/fedsearch/1.1/documentation#" hreflang="en-US" href="http://podaac.jpl.nasa.gov/spurs"></link><link 
            rel="http://esipfed.org/ns/fedsearch/1.1/documentation#" hreflang="en-US" href="https://podaac-tools.jpl.nasa.gov/drive/files/allData/insitu/L2/spurs1/docs/DataDocumentation/"></link><link 
            rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" hreflang="en-US" href="https://podaac-tools.jpl.nasa.gov/drive/files/allData/insitu/L2/spurs1/sw/Matlab"></link><link rel="http://esipfed.org/ns/fedsearch/1.1/browse#" 
            hreflang="en-US" href="https://podaac.jpl.nasa.gov/Podaac/thumbnails/SPURS1_WAVEGLIDER.jpg"></link><link rel="http://esipfed.org/ns/fedsearch/1.1/documentation#" 
            hreflang="en-US" href="https://podaac-tools.jpl.nasa.gov/drive/files/allData/insitu/L2/spurs1/docs/SpursWebsiteContent/"></link><link 
            rel="http://esipfed.org/ns/fedsearch/1.1/documentation#" hreflang="en-US" href="https://podaac-tools.jpl.nasa.gov/drive/files/allData/insitu/L2/spurs1/docs/CruiseReports/"></link><link 
            rel="http://esipfed.org/ns/fedsearch/1.1/service#" hreflang="en-US" href="https://podaac-opendap.jpl.nasa.gov/opendap/allData/insitu/L2/spurs1/waveglider/"></link><link length="0.0KB" 
            rel="http://esipfed.org/ns/fedsearch/1.1/data#" hreflang="en-US" href="https://podaac-tools.jpl.nasa.gov/drive/files/allData/insitu/L2/spurs1/waveglider"></link><link rel="http://esipfed.org/ns/fedsearch/1.1/documentation#" 
            hreflang="en-US" href="https://podaac.jpl.nasa.gov/CitingPODAAC"></link><echo:coordinateSystem>CARTESIAN</echo:coordinateSystem><echo:orbitParameters swathWidth="0.001" period="0.0" inclinationAngle="0.0" 
            numberOfOrbits="1"></echo:orbitParameters><georss:box>23 -71 42 -37</georss:box><echo:onlineAccessFlag>true</echo:onlineAccessFlag><echo:browseFlag>true</echo:browseFlag><echo:hasVariables>false</echo:hasVariables><echo:hasFormats>false</echo:hasFormats><echo:hasTransforms>false</echo:hasTransforms><echo:hasSpatialSubsetting>false</echo:hasSpatialSubsetting><echo:hasTemporalSubsetting>false</echo:hasTemporalSubsetting></entry></feed>', 
            headers: {}
        )

    stub_request(:get, "https://cmr.sit.earthdata.nasa.gov/search/collections.umm_json?concept_id=metric1-PODAAC")
        .with(
            headers: {
                'Accept' => '*/*',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'User-Agent' => 'Ruby'}
        )
        .to_return(status: 200, body: '{"hits":1,"took":8,"items":[{"meta":{"revision-id":4,
            "deleted":false,"format":"application/vnd.nasa.cmr.umm+json",
            "provider-id":"PODAAC","user-id":"mmorahan","has-formats":false,
            "has-spatial-subsetting":false,"native-id":"Waveglider+data+for+the+SPURS-1+N.+Atlantic+field+campaign",
            "has-transforms":false,"has-variables":false,"concept-id":"C1652975935-PODAAC","revision-date":"2021-05-24T15:17:59.132Z",
            "granule-count":0,"has-temporal-subsetting":false,"concept-type":"collection"},"umm":{"DataLanguage":"English",
            "AncillaryKeywords":["Waveglider"," CTD"," trajectory"," Salinity"," Conductivity"," Temperature"," Depth"," Pressure"," Upper Ocean",
            " SPURS1"," North Atlantic Ocean"," salinity maximum region"," insitu"," SPURS"],"CollectionCitations":[{"Creator":"SPURS PROJECT, 
            Fred Bingham","OnlineResource":{"Linkage":"http://podaac.jpl.nasa.gov/SPURS"},"Publisher":"SPURS Data Management PI, Fred Bingham",
            "Title":"SPURS-1 Field Campaign Waveglider Data Products","SeriesName":"Waveglider data for the SPURS-1 N. Atlantic field campaign",
            "OtherCitationDetails":"SPURS PROJECT, Fred Bingham, SPURS Data Management PI, Fred Bingham, 2015-05-11, 
            Waveglider data for the SPURS-1 N. Atlantic field campaign, http://podaac.jpl.nasa.gov/SPURS",
            "ReleaseDate":"2015-05-11T00:00:00.000Z","Version":"1.0","ReleasePlace":"Department of Physics and Physical Oceanography, 
            University on North Carolina, Wilmington, NC, USA"}],"AdditionalAttributes":[{"DataType":"DATETIME",
            "Description":"Earliest Granule Start Time for dataset.","Name":"earliest_granule_start_time","Value":"2012-09-01T00:00:00.000Z"},
            {"DataType":"DATETIME","Description":"Latest Granule Stop/End Time for dataset.","Name":"latest_granule_end_time",
            "Value":"2013-03-25T00:00:00.000Z"},{"DataType":"INT","Description":"Dataset Latency","Name":"data_latency","Value":"9000"},
            {"DataType":"STRING","Description":"Dataset citation series name","Name":"Series Name",
            "Value":"Waveglider data for the SPURS-1 N. Atlantic field campaign"},{"DataType":"STRING","Description":"Dataset Persistent ID",
            "Name":"Persistent ID","Value":"PODAAC-SPUR1-GLID3"}],"SpatialExtent":{"GranuleSpatialRepresentation":"CARTESIAN",
            "HorizontalSpatialDomain":{"Geometry":{"BoundingRectangles":[{"EastBoundingCoordinate":-37.0,"NorthBoundingCoordinate":42,
            "SouthBoundingCoordinate":23,"WestBoundingCoordinate":-71.0}],"CoordinateSystem":"CARTESIAN"},
            "ResolutionAndCoordinateSystem":{"GeodeticModel":{"DenominatorOfFlatteningRatio":298.2572236,"EllipsoidName":"WGS 84",
            "HorizontalDatumName":"World Geodetic System 1984","SemiMajorAxis":6378137},
            "HorizontalDataResolution":{"GenericResolutions":[{"Unit":"Meters","XDimension":1,"YDimension":1}]}}},
            "OrbitParameters":{"InclinationAngle":0.0,"NumberOfOrbits":1,"Period":0.0,"SwathWidth":0.001},
            "SpatialCoverageType":"HORIZONTAL"},"CollectionProgress":"COMPLETE","ScienceKeywords":[{"Category":"EARTH SCIENCE",
            "Term":"OCEAN TEMPERATURE","Topic":"OCEANS","VariableLevel1":"TEMPERATURE PROFILES"},{"Category":"EARTH SCIENCE","Term":"OCEAN WINDS",
            "Topic":"OCEANS","VariableLevel1":"SURFACE WINDS"},{"Category":"EARTH SCIENCE","Term":"OCEAN PRESSURE","Topic":"OCEANS",
            "VariableLevel1":"SURFACE PRESSURE"},{"Category":"EARTH SCIENCE","Term":"OCEAN CIRCULATION","Topic":"OCEANS",
            "VariableLevel1":"CURRENT VELOCITY"},{"Category":"EARTH SCIENCE","Term":"SALINITY/DENSITY","Topic":"OCEANS",
            "VariableLevel1":"CONDUCTIVITY"},{"Category":"EARTH SCIENCE","Term":"SALINITY/DENSITY","Topic":"OCEANS","VariableLevel1":"SALINITY"},
            {"Category":"EARTH SCIENCE","Term":"OCEAN TEMPERATURE","Topic":"OCEANS","VariableLevel1":"SURFACE AIR TEMPERATURE"}],
            "TemporalExtents":[{"RangeDateTimes":[{"BeginningDateTime":"2012-09-01T00:00:00.000Z","EndingDateTime":"2013-03-25T00:00:00.000Z"}]}],
            "ProcessingLevel":{"Id":"2"},"DOI":{"Authority":"https://dx.doi.org/","DOI":"10.5067/SPUR1-GLID3"},"ShortName":"SPURS1_WAVEGLIDER",
            "EntryTitle":"Waveglider data for the SPURS-1 N. Atlantic field campaign","PublicationReferences":[{"OtherReferenceDetails":"E.Lindstrom, 
            F.Bryan, R.Schmitt. 2015. SPURS: Salinity Processes in the Upper-ocean Regional Study - The North Atlantic Experiment. Oceanography 28(1):14-19, 
            http://dx.doi.org/10.5670/oceanog.2015.01."}],"RelatedUrls":[{"Description":"Project Website for SPURS","Subtype":"GENERAL DOCUMENTATION",
            "Type":"VIEW RELATED INFORMATION","URL":"http://spurs.jpl.nasa.gov/","URLContentType":"PublicationURL"},{"Description":"R read software",
            "Type":"DOWNLOAD SOFTWARE","URL":"https://podaac-tools.jpl.nasa.gov/drive/files/allData/insitu/L2/spurs1/sw/R",
            "URLContentType":"DistributionURL"},{"Description":"Field Campaign and Instrument Overview","Subtype":"GENERAL DOCUMENTATION",
            "Type":"VIEW RELATED INFORMATION","URL":"http://podaac.jpl.nasa.gov/spurs","URLContentType":"PublicationURL"},
            {"Description":"Data Submission Report, Instrument Calibration Report, etc","Subtype":"GENERAL DOCUMENTATION",
            "Type":"VIEW RELATED INFORMATION","URL":"https://podaac-tools.jpl.nasa.gov/drive/files/allData/insitu/L2/spurs1/docs/DataDocumentation/",
            "URLContentType":"PublicationURL"},{"Description":"MATLAB read software","Type":"DOWNLOAD SOFTWARE",
            "URL":"https://podaac-tools.jpl.nasa.gov/drive/files/allData/insitu/L2/spurs1/sw/Matlab","URLContentType":"DistributionURL"},
            {"Description":"Thumbnail","Type":"GET RELATED VISUALIZATION","URL":"https://podaac.jpl.nasa.gov/Podaac/thumbnails/SPURS1_WAVEGLIDER.jpg",
            "URLContentType":"VisualizationURL"},{"Description":"Meeting Materials, Cruise Blogs, and other archive artifacts",
            "Subtype":"GENERAL DOCUMENTATION","Type":"VIEW RELATED INFORMATION",
            "URL":"https://podaac-tools.jpl.nasa.gov/drive/files/allData/insitu/L2/spurs1/docs/SpursWebsiteContent/",
            "URLContentType":"PublicationURL"},{"Description":"Cruise Reports","Subtype":"GENERAL DOCUMENTATION","Type":"VIEW RELATED INFORMATION",
            "URL":"https://podaac-tools.jpl.nasa.gov/drive/files/allData/insitu/L2/spurs1/docs/CruiseReports/","URLContentType":"PublicationURL"},
            {"Description":"The OPeNDAP base directory location for the collection.","Subtype":"OPENDAP DATA","Type":"USE SERVICE API",
            "URL":"https://podaac-opendap.jpl.nasa.gov/opendap/allData/insitu/L2/spurs1/waveglider/","URLContentType":"DistributionURL"},
            {"Description":"PO.DAAC Drive","GetData":{"Format":"Not provided","MimeType":"text/html","Size":0.0,"Unit":"KB"},
            "Subtype":"DIRECT DOWNLOAD","Type":"GET DATA","URL":"https://podaac-tools.jpl.nasa.gov/drive/files/allData/insitu/L2/spurs1/waveglider",
            "URLContentType":"DistributionURL"},{"Description":"Data Use and Citation Policy ","Subtype":"DATA CITATION POLICY",
            "Type":"VIEW RELATED INFORMATION","URL":"https://podaac.jpl.nasa.gov/CitingPODAAC","URLContentType":"PublicationURL"}],
            "SpatialInformation":{"SpatialCoverageType":"HORIZONTAL"},"DataDates":[{"Date":"2015-04-07T00:02:24.407Z","Type":"CREATE"},
            {"Date":"2017-04-28T05:01:46.000Z","Type":"UPDATE"}],"Abstract":"The SPURS (Salinity Processes in the Upper Ocean Regional Study) 
            project is an oceanographic process study and associated field program that aim to elucidate key mechanisms responsible for near-surface 
            salinity variations in the oceans. The project involves two field campaigns and a series of cruises in regions of the Atlantic and Pacific 
            Oceans exhibiting salinity extremes.  SPURS employs a suite of state-of-the-art in-situ sampling technologies that, combined with remotely 
            sensed salinity fields from the Aquarius/SAC-D and SMOS satellites, provide a detailed characterization of salinity structure over a 
            continuum of spatio-temporal scales.  The SPURS-1 campaign involved a series of 5 cruises during 2012 - 2013 seeking to characterize the 
            salinity structure and balance in a high salinity, high evaporation, and low rainfall region of the subtropical North Atlantic. 
            It aims to resolve processes responsible for maintaining the subtropical surface salinity maximum in this region and within a 900 x 800-mile
            square study area centered at 25N, 38W. A Waveglider is an autonomous platform propelled by the conversion of ocean wave energy into 
            forward thrust and employing solar panels to power instrumentation. During SPURS-1, three wavegliders (ASL2, ASL3 and ASL4) were deployed 
            from the Knorr in September 2012, redeployed in April 2013 (ASL22, ASL32 and ASL42) with final recovery in September. Waveglider 
            trajectories followed a square loop or butterfly pattern around the central SPURS mooring.  Sensors included a CTD at the near-surface and 
            another at 6 m depth, a surface current meter, air temperature, atmospheric pressure and wind speed sensors providing continuous  
            along-track observations.  NetCDF waveglider data files here contain hour averaged, georeferenced  trajectory data for those parameters 
            and depths.","LocationKeywords":[{"Category":"OTHER","Type":"SPURS-1  N.Atlantic Salinity maximum region"}],
            "MetadataDates":[{"Date":"2021-05-20T01:07:42.245Z","Type":"UPDATE"}],"Version":"1.0",
            "Projects":[{"LongName":"NASA Salinity Processes in the Upper Ocean Regional Study","ShortName":"SPURS"}],
            "UseConstraints":{"LicenseURL":{"Description":"License URL for data use policy",
            "Linkage":"https://earthdata.nasa.gov/earth-observation-data/data-use-policy","MimeType":"text/html","Name":"Data Use Policy"}},
            "DataCenters":[{"Roles":["PROCESSOR"],"ShortName":"SPURS Project"},
            {"ContactPersons":[{"ContactInformation":{"ContactMechanisms":[{"Type":"Telephone","Value":"+1 (910) 962-2383"},
            {"Type":"Email","Value":"binghamf@uncw.edu"}]},"FirstName":"Frederick","LastName":"Bingham","MiddleName":"M","Roles":["Investigator",
            "Technical Contact"]}],"LongName":"SPURS Data manager, Fred Bingham","Roles":["ARCHIVER"],"ShortName":"NASA/JPL/PODAAC"},
            {"ContactPersons":[{"ContactInformation":{"ContactMechanisms":[{"Type":"Telephone","Value":"(818) 393-7165"},
            {"Type":"Email","Value":"podaac@podaac.jpl.nasa.gov"}]},"FirstName":"User","LastName":"Services",
            "Roles":["Investigator","Technical Contact"]}],"LongName":"Physical Oceanography Distributed Active Archive Center, 
            Jet Propulsion Laboratory, NASA","Roles":["ARCHIVER"],"ShortName":"NASA/JPL/PODAAC"}],"TemporalKeywords":["1 Day"],
            "Platforms":[{"Characteristics":[{"DataType":"FLOAT","Description":"Nominal period of a spacecraft`s single revolution on an orbital plane.",
            "Name":"OrbitPeriod","Unit":"Minutes","Value":"0.0"},{"DataType":"FLOAT",
            "Description":"Spacecraft angular distance from orbital plane relative to the Equator.",
            "Name":"InclinationAngle","Unit":"Degrees","Value":"0.0"}],
            "Instruments":[{"Characteristics":[{"DataType":"FLOAT",
            "Description":"Spacecraft angular distance from orbital plane relative to the Equator.",
            "Name":"SwathWidth","Unit":"Kilometers","Value":"0.001"}],"LongName":"Conductivity, Temperature, Depth",
            "ShortName":"CTD"},{"Characteristics":[{"DataType":"FLOAT",
            "Description":"Spacecraft angular distance from orbital plane relative to the Equator.",
            "Name":"SwathWidth","Unit":"Kilometers","Value":"0.001"}],"LongName":"Meteorological Measurement System",
            "ShortName":"MMS"},{"Characteristics":[{"DataType":"FLOAT",
            "Description":"Spacecraft angular distance from orbital plane relative to the Equator.","Name":"SwathWidth","Unit":"Kilometers",
            "Value":"0.001"}],"LongName":"Current Meter","ShortName":"CURRENT METERS"}],"LongName":"SPURS-I WHOI Waveglider",
            "ShortName":"Waveglider","Type":"In Situ Ocean-based Platforms"}],
            "ArchiveAndDistributionInformation":{"FileDistributionInformation":[{"Format":"NETCDF","FormatType":"Native"}]}}}]}',
            headers: {}
        )

    # stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?revision_id=4")
    #     .with(
    #         headers: {'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept' => '*/*', 'User-Agent' => 'Ruby'}
    #     )
    #     .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><results><hits>0</hits><took>32</took></results>', headers: {})
  end

  describe "GET #refresh" do
    it "refreshes a closed record and notifies of no new revision" do
      visit '/home'
      find("#closed_records_button").click
      within '#closed' do
        all('#record_id_')[0].click
      end
      sleep 1
      screenshot_and_open_image
      click_on 'Refresh'
      # assert has_content? 'Latest revision for Collection has already been ingested '
      page.must_have_content(`Latest revision for Collection has already been ingested`)
    end

    it "refreshes a closed record and notifies that a new revision is available to be ingested" do
      visit '/home'
      find("#closed_records_button").click
      within '#closed' do
        all('#record_id_')[0].click
      end
      sleep 1
      screenshot_and_open_image
      click_on 'Refresh'
      page.must_have_content(`Latest revision for Collection has been ingested`)
    end
  end
end