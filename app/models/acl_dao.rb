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
    user_is_daac_curator = false
    user_is_arc_curator = true
    user_is_admin = false

    results = search_acls_by_user(user_id, 1)
    noPages = (results['hits']/2000).ceil
    items = results['items']
    if (items.nil?)
      return nil
    end

    items = Array.wrap(items)
    for i in 2..noPages+1
      results = search_acls_by_user(user_id, i)
      items += Array.wrap(results['items'])
    end

    items.each {|item|
      if item['name'].end_with?"DASHBOARD_DAAC_CURATOR"
        user_is_daac_curator = true
      end
      if item['name'].end_with?"DASHBOARD_ARC_CURATOR"
        user_is_arc_curator =  true
      end
      if item['name'].end_with?"DASHBOARD_ADMIN"
        user_is_admin = true;
      end
    }

    #
    # returns the highest level role
    #
    role = nil
    if (user_is_admin)
      role = 'admin'
    else
      if (user_is_daac_curator)
        role = 'daac_curator'
      else
        if (user_is_arc_curator)
          role = 'arc_curator'
        end
      end
    end
    role

  end

  private

    def create_system_level_group(name, description, members)
      data = {
        "name": name,
        "description": description,
        "members": members
      }
      send_request_to_cmr(:POST,'/access-control/groups', data)

    end

    def create_provider_level_group(name, description, provider_id)
      data = {
        "name": name,
        "provider_id": provider_id,
        "description": description,
      }
      send_request_to_cmr(:POST, '/access-control/groups', data)
    end

    def delete_group(concept_id)
      send_request_to_cmr(:DELETE, "/access-control/groups/#{concept_id}")
    end

    def add_group_members(concept_id, users)
      send_request_to_cmr(:POST, "/access-control/groups/#{concept_id}/members", users)
    end

    def remove_group_members(concept_id, users)
      send_request_to_cmr(:DELETE, "/access-control/groups/#{concept_id}/members", users)
    end

    def search_acls_by_target(target)
      json = send_request_to_cmr(:GET , "/access-control/acls?target=#{target}")
      json
    end

    def search_acls_by_user(user_id, page_no)
      json = send_request_to_cmr(:GET , "/access-control/acls?permitted_user=#{user_id}&page_size=2000&page_num=#{page_no}")
      json
    end

    def retrieve_json_from_url(url)
      conn = Faraday.new(:url => url) do |faraday|
        faraday.headers['Echo-Token'] = "#{@access_token}:#{slpVL3U6ycqIxyyAkEHb1g}:#{ENV['urs_client_id']}"
        faraday.response :logger # log requests to $stdout
        faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
      end
      response = conn.get
      json = JSON.parse(response.body)
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



