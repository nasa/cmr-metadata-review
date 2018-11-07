class AclDao
  attr_accessor :access_token, :client_id, :base_url

  def initialize(token, client_id, base_url)
    @access_token = token
    @client_id = client_id
    @base_url = base_url
  end

  def get_role(user_id)

    # Sets whether the user is a specific role type
    # Note: user could be all three.

    results = search_acls_by_user(user_id, 1)
    noPages = (results['hits']/2000).ceil
    items = Array.wrap(results['items'])

    (2..noPages+1).each do |i|
      results = search_acls_by_user(user_id, i)
      items += Array.wrap(results['items'])
    end

    roles = Set.new
    items.each do |item|
      roles << "daac_curator" if item['name'].end_with?"DASHBOARD_DAAC_CURATOR"
      roles << "arc_curator" if item['name'].end_with?"DASHBOARD_ARC_CURATOR"
      roles << "admin" if item['name'].end_with?"DASHBOARD_ADMIN"
    end

    #
    # returns the highest level role
    #
    return "admin" if roles.include? "admin"
    return "daac_curator" if roles.include? "daac_curator"
    return "arc_curator" if roles.include? "arc_curator"

    nil
  end

  private
    def search_acls_by_user(user_id, page_no)
      json = send_request_to_cmr(:GET , "/access-control/acls?permitted_user=#{user_id}&page_size=2000&page_num=#{page_no}")
      json
    end

    def send_request_to_cmr(action, endpoint, data = nil)
      conn = Faraday.new(:url => @base_url) do |faraday|
        faraday.headers['Echo-Token'] = "#{@access_token}:#{ENV['urs_client_id']}"
        faraday.request :json
        faraday.response :logger # log requests to $stdout
        faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
      end
      case action
        when :DELETE
          response = conn.delete endpoint, data
        when :PUT
          response = conn.put endpoint, data
        when :POST
          response = conn.post endpoint, data
        when :GET
          response = conn.get endpoint, data
      end
      json = JSON.parse(response.body)
      json
    end
end



