class Cmr
  def self.get_collection(concept_id)
    collection_xml = HTTParty.get("https://cmr.earthdata.nasa.gov/search/collections.echo10?concept_id=#{concept_id}").parsed_response
    collection_results = Hash.from_xml(collection_xml)["results"]
    collection_results["result"]
  end
end