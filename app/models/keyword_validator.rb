class KeywordValidator

  def initialize
    super
  end

  def validate_keywords(providers = get_providers)
    checker = KeywordChecker.new
    updated_since = CmrSync.get_sync_date
    providers.each do |provider|
      concept_id_compound = CmrSync.get_concepts(provider, 2000, updated_since)
      concept_ids = concept_id_compound.map{|cidc| cidc[0]}
      InvalidKeyword.transaction do
        InvalidKeyword.remove_invalid_keywords(concept_ids)
        concept_id_compound.each do |cidc|
          concept_id = cidc[0]
          revision_id = cidc[1]
          short_name = cidc[2]
          version_id = cidc[3]
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
  end

  def get_providers
    return ApplicationHelper::ARC_PROVIDERS
  end
end