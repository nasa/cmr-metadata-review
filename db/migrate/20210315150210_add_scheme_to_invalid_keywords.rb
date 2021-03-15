class AddSchemeToInvalidKeywords < ActiveRecord::Migration[5.2]
  def up
    add_column :invalid_keywords, :scheme, :string
    InvalidKeyword.all.each do |record|
      record.scheme = getScheme(record.ummc_field)
      record.save
    end
  end

  def down
    remove_column :invalid_keywords, :scheme
  end

  def getScheme(ummc_field)
    scheme = ''
    case ummc_field
    when 'ScienceKeywords'
      scheme = 'sciencekeywords'
    when 'Platforms'
      scheme = 'platforms'
    when 'Instruments'
      scheme = 'instruments'
    when 'Projects'
      scheme = 'projects'
    when 'DataCenters'
      scheme = 'providers'
    when 'ProcessingLevel'
      scheme = 'ProductLevelId'
    when 'ArchiveAndDistributionInformation'
      scheme = 'GranuleDataFormat'
    end
    return scheme
  end
end
