class CmrSync < ApplicationRecord
  # updates the sync table with the latest datetime of the sync
  def self.update_sync_date(update_date)
    info = CmrSync.find_by id: 1
    if info.nil?
      info = CmrSync.new
      info.id = 1
    end
    info.updated_since = update_date
    info.save!
  end

  # return datetime of the last sync
  def self.get_sync_date
    info = CmrSync.find_by id: 1
    if info.nil?
      return nil
    else
      return info.updated_since
    end
  end

  # Given the specified concept id, revision id, format fetch the concept from CMR and returns the concept as a hash.
  def self.get_concept(concept_id, revision_id = nil, format = nil)
    url = "#{Cmr.get_cmr_base_url}/search/concepts/#{concept_id}#{revision_id.nil? ? "" : "/#{revision_id}"}#{format.nil? ? "" : ".#{format}"}"
    Cmr.convert_to_hash(format, Cmr.cmr_request(url).body)
  end

  # Given the specified provider and max_page_size, fetch from CMR and return concept_ids as a list of tuples (concept_id, revision_id, short_name, version)
  def self.get_concepts(provider, max_page_size = 2000, updated_since=nil)
    page_no = 1
    no_pages = 1
    concept_ids = []

    if updated_since.nil?
      updated_since = '1971-01-01T12:00:00Z'
    else
      updated_since = updated_since.utc.iso8601
    end

    user = UserSingleton.instance
    current_user = user.current_user

    conn = Faraday.new(:url => "#{Cmr.get_cmr_base_url}") do |faraday|
      faraday.headers['Echo-Token'] = user.echo_token unless Cmr.isTestUser(current_user)
      faraday.response :logger
      faraday.adapter Faraday.default_adapter
    end

    while  page_no <= no_pages
      query = "/search/collections.umm-json?page_size=#{max_page_size}&page_num=#{page_no}&updated_since=#{URI.encode(updated_since)}"
      unless provider.nil?
        query += "&provider=#{provider}"
      end
      response = conn.get query
      headers = response.headers
      if page_no == 1
        no_hits = headers['cmr-hits'].to_i
        no_pages = (no_hits / max_page_size) + 1
      end
      dict = JSON.parse(response.body)
      items = dict['items']
      items.each do |item|
        meta = item['meta']
        umm = item['umm']
        concept_ids << [meta['concept-id'],meta['revision-id'],umm['short-name'],umm['version-id']]
      end

      page_no += 1
    end
    concept_ids
  end

end
