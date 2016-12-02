class Api::V1::CollectionsController < Api::V1::BaseController
  before_filter :find_record

  def show
    stat = StatGenerator.new(@record, params[:user_id], params)
    render json: stat.extract_data
  end

  def take_for_review
    review_detail = @record.review_details.find_or_create_by(user_id: params[:user_id])
    render json: review_detail.data
  end

  def review
    review_detail = @record.review_details.where(user_id: params[:user_id]).last
    review_detail.review
    render json: review_detail.data
  end

  def recommend
    stat = StatGenerator.new(@record, params[:user_id], params)
    if params['recommended'].present?
      stat.update_recommendation
    elsif params['reason'].present?
      stat.update_reason
    end
    render json: stat.extract_data
  end

  def random_granule
    @record.assign_random_granule if @record.granule_stat.blank?
    render json: @record.granule_stat
  end

  private

  def find_record
    id = params[:id] || params[:collection_id] || params[:granule_id]
    @record = if id.match(/G(\d|[a-z]|[A-Z])+\-[A-Z]+/)
                GranuleStat.where(granule_id: id).last
              else
                CollectionStat.where(concept_id: id).last
              end
  end

end