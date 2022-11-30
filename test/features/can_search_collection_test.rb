require 'test_helper'
Dir[Rails.root.join('test/**/*.rb')].each { |f| require f }

class CanSearchCollectionTest < SystemTestCase
  include Helpers::UserHelpers
  include Helpers::ReviewsHelper
  include Helpers::CollectionsHelper
  include Helpers::HomeHelper

  before do
    OmniAuth.config.test_mode = true
    mock_login(role: 'admin')
    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/collections.echo10?keyword=**&page_num=1&page_size=10&provider=LANCEAMSR2").
        with(
            headers: {
                'Accept'=>'*/*',
                'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'User-Agent'=>'Ruby'
            }).
        to_return(status: 200, body: get_stub('search_collection_provider_ghrc.xml'), headers: {})
    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/collections.echo10?concept_id=C1996546695-GHRC_DAAC").
        with(
            headers: {
                'Accept'=>'*/*',
                'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'User-Agent'=>'Ruby'
            }).
        to_return(status: 200, body: get_stub('search_collection_C1996546695-GHRC_DAAC.xml'), headers: {})
    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.echo10?concept_id=C1996546695-GHRC_DAAC&page_num=1&page_size=10").
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><results><hits>0</hits><took>8</took></results>", headers: {})
    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/collections.atom?concept_id=C1996546695-GHRC_DAAC").
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: get_stub("search_collection_C1996546695-GHRC_DAAC.atom"), headers: {})
    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/concepts/C1996546695-GHRC_DAAC.echo10").
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: get_stub("C1996546695-GHRC_DAAC_echo10.xml"), headers: {})
    stub_request(:get, "#{Cmr.get_cmr_base_url}/search/granules.umm_json?collection_concept_id=C1996546695-GHRC_DAAC&page_size=10&page_num=1").
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: '{"hits" : 0, "took" : 105, "items" : []}', headers: {})
      stub_request(:post, "https://quarc.nasa-impact.net/validate").
        with(
          body: "{\"data\":{\"format\":\"echo-c\"},\"files\":{\"file\":{\"ShortName\":\"rssmif17d\",\"VersionId\":\"7\",\"InsertTime\":\"2012-07-02T10:49:53Z\",\"LastUpdate\":\"2018-04-11T14:28:53Z\",\"LongName\":\"RSS SSMIS OCEAN PRODUCT GRIDS DAILY FROM DMSP F17 NETCDF\",\"DataSetId\":\"RSS SSMIS OCEAN PRODUCT GRIDS DAILY FROM DMSP F17 NETCDF V7\",\"Description\":\"The RSS SSMIS Ocean Product Grids Daily from DMSP F17 netCDF dataset is part of the collection of Special Sensor Microwave/Imager (SSM/I) and Special Sensor Microwave Imager Sounder (SSMIS) data products produced as part of NASA's MEaSUREs Program. Remote Sensing Systems generates SSM/I and SSMIS binary data products using a unified, physically based algorithm to simultaneously retrieve ocean wind speed, water vapor, cloud water, and rain rate. The SSMIS data have been carefully intercalibrated to the brightness temperature level of the previous SSM/I and therefore extend this important time series of ocean winds, vapor, cloud and rain values. This algorithm is a product of 20 years of refinements, improvements, and verifications. The Global Hydrology Resource Center has reformatted the binary data into a netCDF data product for each temporal group for each satellite. The netCDF SSMI/SSMIS collection will be available for F17 daily.\",\"Orderable\":\"true\",\"Visible\":\"true\",\"ProcessingLevelId\":\"3\",\"ProcessingLevelDescription\":\"https://ghrc.nsstc.nasa.gov/home/proc_level\",\"ArchiveCenter\":\"NASA/MSFC/GHRC\",\"CitationForExternalPublication\":\"Wentz, Frank J, Kyle Hilburn and Deborah K Smith.2012. RSS SSMIS OCEAN PRODUCT GRIDS DAILY FROM DMSP F17 NETCDF [indicate subset used]. Dataset available online from the NASA Global Hydrology Resource Center DAAC, Huntsville, Alabama, U.S.A. DOI: http://dx.doi.org/10.5067/MEASURES/DMSP-F17/SSMIS/DATA301\",\"CollectionState\":\"IN WORK\",\"RestrictionFlag\":\"0\",\"RestrictionComment\":\"This product has full public access.\",\"UseConstraints\":{\"LicenseURL\":{\"URL\":\"https://earthdata.nasa.gov/earth-observation-data/data-use-policy\",\"Description\":\"License URL for data use policy\",\"Type\":\"Data Use Policy\",\"MimeType\":\"text/html\"}},\"Price\":\"0.0\",\"DataFormat\":\"netCDF-4\",\"SpatialKeywords\":{\"Keyword\":\"GLOBAL\"},\"TemporalKeywords\":{\"Keyword\":\"Daily - \\u003c Weekly\"},\"Temporal\":{\"RangeDateTime\":{\"BeginningDateTime\":\"2006-12-14T00:00:00Z\"}},\"Contacts\":{\"Contact\":{\"Role\":\"ARCHIVER\",\"OrganizationName\":\"Global Hydrology Resource Center, Marshall Space Flight Center, NASA\",\"OrganizationAddresses\":{\"Address\":{\"StreetAddress\":\"320 Sparkman Drive\",\"City\":\"Huntsville\",\"StateProvince\":\"Alabama\",\"PostalCode\":\"35805\",\"Country\":\"USA\"}},\"OrganizationPhones\":{\"Phone\":[{\"Number\":\"+1 256-961-7932\",\"Type\":\"Telephone\"},{\"Number\":\"+1 256-824-5149\",\"Type\":\"Fax\"}]},\"OrganizationEmails\":{\"Email\":\"support-ghrc@earthdata.nasa.gov\"}}},\"ScienceKeywords\":{\"ScienceKeyword\":[{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"Spectral/Engineering\",\"TermKeyword\":\"Precipitation\",\"VariableLevel1Keyword\":{\"Value\":\"Precipitation Rate\"}},{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"Oceans\",\"TermKeyword\":\"Ocean Winds\",\"VariableLevel1Keyword\":{\"Value\":\"Surface Winds\"}},{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"Atmosphere\",\"TermKeyword\":\"Atmospheric Winds\",\"VariableLevel1Keyword\":{\"Value\":\"Surface Winds\"}},{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"Atmosphere\",\"TermKeyword\":\"Atmospheric Water Vapor\",\"VariableLevel1Keyword\":{\"Value\":\"Water Vapor Indicators\",\"VariableLevel2Keyword\":{\"Value\":\"Water Vapor\"}}},{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"Atmosphere\",\"TermKeyword\":\"Clouds\",\"VariableLevel1Keyword\":{\"Value\":\"Cloud Microphysics\",\"VariableLevel2Keyword\":{\"Value\":\"Cloud Liquid Water/Ice\"}}},{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"Atmosphere\",\"TermKeyword\":\"Precipitation\",\"VariableLevel1Keyword\":{\"Value\":\"Liquid Precipitation\",\"VariableLevel2Keyword\":{\"Value\":\"Rain\"}}}]},\"Platforms\":{\"Platform\":{\"ShortName\":\"DMSP 5D-3/F17\",\"LongName\":\"Defense Meteorological Satellite Program-F17\",\"Type\":\"Earth Observation Satellites\",\"Instruments\":{\"Instrument\":{\"ShortName\":\"SSMIS\",\"LongName\":\"Special Sensor Microwave Imager/Sounder\"}}}},\"Campaigns\":{\"Campaign\":{\"ShortName\":\"DISCOVER\",\"LongName\":\"Distributed Info. Services for Climate/Ocean Prod./Visualizations for Earth Res.\"}},\"OnlineAccessURLs\":{\"OnlineAccessURL\":{\"URL\":\"https://ghrc.nsstc.nasa.gov/pub/ssmis/f17/daily/data/\",\"URLDescription\":\"Files may be downloaded directly to your workstation from this link\"}},\"OnlineResources\":{\"OnlineResource\":[{\"URL\":\"https://ghrc.nsstc.nasa.gov/pub/ssmis/f17/daily/browse/2011/f17_ssmis_20110430v7_D_CW.png\",\"Description\":\"Sample browse image\",\"Type\":\"BROWSE\",\"MimeType\":\"image/png\"},{\"URL\":\"https://ghrc.nsstc.nasa.gov/pub/ssmis/f17/daily/browse/2011/f17_ssmis_20110430v7_D_RR.png\",\"Description\":\"Sample browse image\",\"Type\":\"BROWSE\",\"MimeType\":\"image/png\"},{\"URL\":\"https://ghrc.nsstc.nasa.gov/pub/ssmis/f17/daily/browse/2011/f17_ssmis_20110430v7_D_WV.png\",\"Description\":\"Sample browse image\",\"Type\":\"BROWSE\",\"MimeType\":\"image/png\"},{\"URL\":\"https://ghrc.nsstc.nasa.gov/pub/ssmis/f17/daily/browse/2011/f17_ssmis_20110430v7_D_WS.png\",\"Description\":\"Sample browse image\",\"Type\":\"BROWSE\",\"MimeType\":\"image/png\"},{\"URL\":\"https://ghrc.nsstc.nasa.gov/pub/doc/ssmi_netcdf/SSMI_Data_in_NetCDF.docx\",\"Description\":\"GHRC at UAH - SSM/I and SSMIS Data in NetCDF User's Guide\",\"Type\":\"GENERAL DOCUMENTATION\"},{\"URL\":\"http://dx.doi.org/10.5067/MEASURES/SSMI-SSMIS/DATA301\",\"Description\":\"Digital Object Identifier for a collection of related datasets\",\"Type\":\"VIEW RELATED INFORMATION\"},{\"URL\":\"http://ghrc.nsstc.nasa.gov/uso/ds_docs/ssmi_netcdf/ssmi_ssmis_dataset.html\",\"Description\":\"The guide document contains detailed information about the dataset\",\"Type\":\"USER'S GUIDE\",\"MimeType\":\"text/html\"},{\"URL\":\"https://ghrc.nsstc.nasa.gov/pub/doc/ssmi_netcdf/rain.pdf\",\"Description\":\"SSM/I Rain Retrievals Within an Unified All-Weather Ocean Algorithm\",\"Type\":\"PI DOCUMENTATION\",\"MimeType\":\"application/pdf\"},{\"URL\":\"https://ghrc.nsstc.nasa.gov/pub/doc/ssmi_netcdf/ssmi.pdf\",\"Description\":\"A Well Calibrated Ocean Algorithm for SSM/I\",\"Type\":\"PI DOCUMENTATION\",\"MimeType\":\"application/pdf\"},{\"URL\":\"https://ghrc.nsstc.nasa.gov/pub/doc/ssmi_netcdf/Hilburn_V7_Poster_AMS_SatMet_2010_Annapolis.pdf\",\"Description\":\"Description of Remote Sensing Systems Version-7 Geophysical Retrievals\",\"Type\":\"PI DOCUMENTATION\",\"MimeType\":\"application/pdf\"},{\"URL\":\"https://ghrc.nsstc.nasa.gov/opendap/ssmis/f17/daily/\",\"Description\":\"OPeNDAP server dataset access\",\"Type\":\"OPENDAP DATA\"},{\"URL\":\"https://ghrc.nsstc.nasa.gov/pub/doc/ssmi_netcdf/AMSR_Ocean_Algorithm_Version_2_Supplement_1.pdf\",\"Description\":\"AMSR Ocean Algorithm documentation supplement\",\"Type\":\"ALGORITHM DOCUMENTATION\",\"MimeType\":\"application/pdf\"},{\"URL\":\"https://ghrc.nsstc.nasa.gov/pub/doc/ssmi_netcdf/AMSR_Ocean_Algorithm_Version_2.pdf\",\"Description\":\"AMSR Ocean Algorithm documentation\",\"Type\":\"ALGORITHM DOCUMENTATION\",\"MimeType\":\"application/pdf\"},{\"URL\":\"https://ghrc.nsstc.nasa.gov/pub/doc/ssmi_netcdf/2012_Wentz_011012_Version-7_SSMI_Calibration.pdf\",\"Description\":\"SSM/I Version-7 Calibration Report\",\"Type\":\"ALGORITHM DOCUMENTATION\",\"MimeType\":\"application/pdf\"},{\"URL\":\"https://ghrc.nsstc.nasa.gov/pub/doc/ssmi_netcdf/ReadNetCDF.c\",\"Description\":\"netCDF read software\",\"Type\":\"DOWNLOAD SOFTWARE\",\"MimeType\":\"text/plain\"},{\"URL\":\"https://ghrc.nsstc.nasa.gov/pub/ssmis/f17/daily/browse/\",\"Description\":\"N/A\",\"Type\":\"GET RELATED VISUALIZATION\"},{\"URL\":\"https://ghrc.nsstc.nasa.gov/home/about-ghrc/citing-ghrc-daac-data\",\"Description\":\"Instructions for citing GHRC data\",\"Type\":\"DATA CITATION POLICY\"}]},\"AssociatedDIFs\":{\"DIF\":{\"EntryId\":\"rssmif17d\"}},\"Spatial\":{\"SpatialCoverageType\":\"Horizontal\",\"HorizontalSpatialDomain\":{\"Geometry\":{\"CoordinateSystem\":\"CARTESIAN\",\"BoundingRectangle\":{\"WestBoundingCoordinate\":\"-180\",\"NorthBoundingCoordinate\":\"90\",\"EastBoundingCoordinate\":\"180\",\"SouthBoundingCoordinate\":\"-90\"}}},\"GranuleSpatialRepresentation\":\"CARTESIAN\"}}}}",
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type'=>'application/json',
            'User-Agent'=>'Faraday v1.4.1'
          }).
        to_return(status: 200, body: "{}", headers: {})
  end
  describe 'search cmr collection' do

    # This test fails due to a bug in pyQuARC:
    it 'search collection by GHRC provider' do
      visit '/home'
      within '#provider' do
        find("#provider > option:nth-child(6)").click
      end
      find("#search_button").click
      assert has_content?('C1996543397-GHRC_DAAC')
      assert has_content?('C1996546695-GHRC_DAAC')
      assert has_content?('C1979115640-GHRC_DAAC')
      assert has_content?('C1979116062-GHRC_DAAC')
      find('#search3').click
      click_on 'Select Collection'
      click_on 'Ingest Collection Without Granule'
      assert has_content?('C1996546695-GHRC_DAAC')
    end
  end
end
