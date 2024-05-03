module UmmcToIso19115Helper
  def getIsoFieldMapping(ummJsonField)
    map = IsoFieldMapping.instance.mapping('iso19115')
    value = map[ummJsonField]
    if value.blank?
      value = "No ISO mapping available"
    end
    value
  end
end