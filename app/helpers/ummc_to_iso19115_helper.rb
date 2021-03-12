module UmmcToIso19115Helper
  def getISOFieldMapping(ummJsonField)
    map = ISOFieldMapping.instance.mapping('iso19115')
    value = map[ummJsonField]
    if value.blank?
      value = "No ISO mapping available"
    end
    value
  end
end