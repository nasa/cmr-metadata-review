class ReportsControllerTest < ActionController::TestCase

  setup do
    @cmr_base_url = Cmr.get_cmr_base_url
  end

  describe "GET #home" do  
    it "gets home csv without error" do
        @tester = User.find_by_email("abaker@element84.com")
        sign_in(@tester)
        
        #took stub for total collection count from cmr test
        stub_request(:get, "#{@cmr_base_url}/search/collections.echo10?page_size=1&provider=NSIDCV0&provider=ORNL_DAAC&provider=LARC_ASDC&provider=LARC&provider=LAADS&provider=GES_DISC&provider=GHRC&provider=SEDAC&provider=ASF&provider=LPDAAC_ECS&provider=LANCEMODIS&provider=NSIDC_ECS&provider=OB_DAAC&provider=CDDIS&provider=LANCEAMSR2&provider=PODAAC").with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => '<?xml version=\"1.0\" encoding=\"UTF-8\"?><results><hits>6381</hits><took>33</took><result></result></results>', :headers => {"date"=>["Fri, 24 Mar 2017 15:36:33 GMT"], "content-type"=>["application/echo10+xml; charset=utf-8"], "access-control-expose-headers"=>["CMR-Hits, CMR-Request-Id"], "access-control-allow-origin"=>["*"], "cmr-hits"=>["32728"], "cmr-took"=>["33"], "cmr-request-id"=>["8633b6cd-cc02-4147-91b2-e0236fd1b72a"], "vary"=>["Accept-Encoding, User-Agent"], "connection"=>["close"], "server"=>["Jetty(9.2.z-SNAPSHOT)"], "strict-transport-security"=>["max-age=31536000"]})
        get :home, format: :csv

        assert_equal((response.body.include? "CMR System Wide Report"), true)
    end
  end

  describe "GET #provider" do  
    it "gets provider csv without error" do
        @tester = User.find_by_email("abaker@element84.com")
        sign_in(@tester)
        
        #took stub for total collection count from cmr test
        stub_request(:get, "#{@cmr_base_url}/search/collections.echo10?page_size=1&provider=NSIDCV0&provider=ORNL_DAAC&provider=LARC_ASDC&provider=LARC&provider=LAADS&provider=GES_DISC&provider=GHRC&provider=SEDAC&provider=ASF&provider=LPDAAC_ECS&provider=LANCEMODIS&provider=NSIDC_ECS&provider=OB_DAAC&provider=CDDIS&provider=LANCEAMSR2&provider=PODAAC").with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => '<?xml version=\"1.0\" encoding=\"UTF-8\"?><results><hits>6381</hits><took>33</took><result></result></results>', :headers => {"date"=>["Fri, 24 Mar 2017 15:36:33 GMT"], "content-type"=>["application/echo10+xml; charset=utf-8"], "access-control-expose-headers"=>["CMR-Hits, CMR-Request-Id"], "access-control-allow-origin"=>["*"], "cmr-hits"=>["32728"], "cmr-took"=>["33"], "cmr-request-id"=>["8633b6cd-cc02-4147-91b2-e0236fd1b72a"], "vary"=>["Accept-Encoding, User-Agent"], "connection"=>["close"], "server"=>["Jetty(9.2.z-SNAPSHOT)"], "strict-transport-security"=>["max-age=31536000"]})
        get :provider, daac: "PODAAC", format: :csv

        assert_equal((response.body.include? "CMR DAAC Report"), true)
    end
  end

  describe "GET #selection" do  
    it "gets selection csv without error" do
        @tester = User.find_by_email("abaker@element84.com")
        sign_in(@tester)

        get :selection, records: "C1000000020-LANCEAMSR2,8", format: :csv

        assert_equal((response.body.include? "CMR Selection Report"), true)
    end
  end

end