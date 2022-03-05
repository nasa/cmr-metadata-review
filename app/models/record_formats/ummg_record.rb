# RecordFormats are modules to be included in record objects upon initialization
#
# Since individual record formats have different underlying structures of RecordData objects
# unique accessors are needed for each format to access commonly requested data.
module RecordFormats
  module UmmGRecord
    def get_section_titles
      SectionTitles.instance.get_format_fields('ummg')
    end

    def field_required?(field)
      RequiredFields.instance.get_format_fields('ummg').include?(field)
    end

    # There is no script yet for UMM collections
    def create_script(raw_data = nil)
      nil
    end

    def evaluate_script(raw_data = nil)
      {}
    end

    def controlled_element_map
      ControlledElements.instance.mapping("umm-g")
    end
  end
end
