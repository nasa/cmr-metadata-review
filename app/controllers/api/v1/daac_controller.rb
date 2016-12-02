class Api::V1::DaacController < Api::V1::BaseController
  def index
    results = []
    results = DaacStat.all.map do |stat|
                total = stat.total_records
                reviewed = stat.checked_records
                if total > 0
                  percentage = (100.0 * stat.checked_records) / stat.total_records
                end
                {
                  'name' => stat.name,
                  'reviewed_count' => reviewed,
                  'total_count' => stat.total_records,
                  'percentage' => '%.2f' % (percentage || 0)
                }
              end
    render json: results
  end

  def show
    daac = DaacStat.where(name: params[:id]).last
    resource = params['resource'];
    if resource == 'collections'
      result = daac.collection_stats.map do |collection|
                 {
                   concept_id: collection.concept_id,
                   granule_count: collection.granule_count,
                   entry_title: collection.entry_title,
                   granule_id: collection.granule_stat&.granule_id
                 }
               end
    elsif resource == 'granules'
      result = GranuleStat.where(:collection_stat_id.in => daac.collection_stat_ids).map do |granule|
                 {
                   granule_id: granule.granule_id,
                   location: granule.location,
                   collection_id: granule.collection_stat.concept_id
                 }
               end
    end
    render json: { name: daac.name, collections: result }
  end
end