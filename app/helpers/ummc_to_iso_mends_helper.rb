module UmmcToIsoMendsHelper
  def getISOMendsFieldMappingSections(ummJsonField)
    map = IsoFieldMapping.instance.mapping('iso-mends')
    value = map[ummJsonField]
    value = 'No field mapping found.' if value.blank?
    sections = [ummJsonField]
    if value.sub(' ', '').start_with? '[=>', '[==>'
      field = ummJsonField
      loop do
        pos = field.rindex('/')
        break if pos.nil?
        parent_field = field[0...pos]
        value = map[parent_field]
        sections << parent_field unless value.nil?
        field = parent_field
      end
    end
    sections.reverse!
  end

  def getISOMendsFieldText(field)
    map = IsoFieldMapping.instance.mapping('iso-mends')
    value = map[field]
    return "\nNo field mapping found." if value.blank?
    "\n\n#{map[field]}\n\n"
  end
end