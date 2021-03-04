class KeywordValidator

  def initialize
    super
  end

  def self.validate_keywords(providers = KeywordValidator.get_providers)
    checker = KeywordChecker.new

    # force full sync on weekends
    if Date.today.on_weekend?
      updated_since = nil
    else
      updated_since = CmrSync.get_sync_date
    end

    updated_now = Date.new
    records_processed = 0
    providers.each do |provider|
      Rails.logger.info "Retrieving concepts for #{provider} using #{updated_since.utc.iso8601}"
      concept_id_compound = CmrSync.get_concepts(provider, 2000, updated_since)
      concept_ids = concept_id_compound.map{|cidc| cidc[0]}
      records_processed += concept_ids.length
      InvalidKeyword.transaction do
        if Date.today.on_weekend?
          InvalidKeyword.remove_all_invalid_keywords(provider)
        else
          InvalidKeyword.remove_invalid_keywords(concept_ids)
        end
        concept_id_compound.each do |cidc|
          concept_id = cidc[0]
          revision_id = cidc[1]
          short_name = cidc[2]
          version_id = cidc[3]
          Rails.logger.info("Processing invalid keywords for #{concept_id} -- #{provider} ")
          doc = CmrSync.get_concept(concept_id, revision_id, 'umm_json')
          KeywordChecker::SCHEMES.each do |scheme|
            invalid_keywords = checker.get_invalid_keywords(doc, scheme)
            ummc_field = checker.get_ummc_field(scheme)
            invalid_keywords.each do |invalid_keyword|
              invalid_keyword_model = InvalidKeyword.create_invalid_keyword(provider, concept_id, revision_id, short_name, version_id,
              invalid_keyword, '', ummc_field)
              invalid_keyword_model.save!
            end
          end
        end
      end
    end
    CmrSync.update_sync_date(updated_now)
    records_processed
  end

  def self.get_providers
    return ApplicationHelper::ARC_PROVIDERS
  end
end