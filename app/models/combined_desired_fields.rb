class CombinedDesiredFields
  def self.get_format_fields(format)
    RequiredFields.instance.get_format_fields(format).concat(DesiredFields.instance.get_format_fields(format))
  end
end