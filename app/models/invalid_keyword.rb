class InvalidKeyword < ApplicationRecord
  def self.create_invalid_keyword(provider_id, scheme, concept_id, revision_id, short_name, version,
    invalid_keyword_path, valid_keyword_path, ummc_field)
    keyword = InvalidKeyword.new
    keyword.provider_id = provider_id
    keyword.scheme = scheme
    keyword.concept_id = concept_id
    keyword.revision_id = revision_id
    keyword.short_name = short_name
    keyword.version = version
    keyword.invalid_keyword_path = invalid_keyword_path
    keyword.valid_keyword_path = valid_keyword_path unless valid_keyword_path.nil?
    keyword.ummc_field = ummc_field
    return keyword
  end

  def self.get_invalid_keywords(provider)
    if provider.nil?
      InvalidKeyword.all
    else
      InvalidKeyword.where(provider_id: provider)
    end
  end

  def self.remove_invalid_keywords(concept_ids)
    InvalidKeyword.where(concept_id: concept_ids).delete_all
  end

  def self.remove_all_invalid_keywords(provider)
    InvalidKeyword.where(provider_id: provider).delete_all
  end

  def self.to_csv
    column_names = %w(provider_id concept_id revision_id short_name version ummc_field invalid_keyword_path valid_keyword_path)
    ordered_names = %w(provider_id concept_id revision_id short_name version ummc_field invalid_keyword_path suggested_keyword)
    csv_string = CSV.generate do |csv|
      csv << ordered_names
      all.find_each do |model|
        csv << model.attributes.values_at(*column_names)
      end
    end
    csv_string
  end

end
