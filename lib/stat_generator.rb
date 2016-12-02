class StatGenerator
  attr_accessor :collection, :collection_id, :current_user_id, :params

  def initialize(collection, current_user_id, params)
    @collection = collection
    @current_user_id = current_user_id
    @params = params
    @collection_id = collection.class.to_s == 'CollectionStat' ? 'concept_id' : 'granule_id'
  end

  def elements
    # fields = $redis.lrange('collection:fields', 0, -1)
    # fields.delete('revision_id')
    fields = collection.latest_version.data.keys
    fields.map do |field|
      {
        name: field,
        previous_value: collection.latest_version.data[field],
        recommended: collection.recommended.data[field],
        reason: collection.reasons.data[field],
        latest_value: collection.latest_version.data[field]
      }
    end
  end

  def update_recommendation
    field = params['name']
    recommended_data = collection.recommended.data
    recommended_data[field] = params['recommended']
    collection.recommended.update_attributes(data: recommended_data)
    collection.save
  end

  def update_reason
    field = params['name']
    reason_data = collection.reasons.data
    reason_data[field] = params['reason']
    collection.reasons.update_attributes(data: reason_data)
    collection.save
  end

  def extract_data
    {
      "#{collection_id}": collection.send("#{collection_id}"),
      previous_version: collection.latest_version.data['revision_id'],
      latest_version: collection.latest_version.data['revision_id'],
      elements: elements,
      review: collection.review_details.where(user_id: current_user_id).last&.data,
      history: ReviewDetail.histories(collection_id: collection.id)
    }
  end

end