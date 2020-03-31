# RecordFormats are modules to be included in record objects upon initialization
#
# Since individual record formats have different underlying structures of RecordData objects
# unique accessors are needed for each format to access commonly requested data.
module RecordFormats
  module UmmRecord
    include RecordFormats::UmmFields

    LONG_NAME_FIELD = "EntryTitle"

    def get_section_titles
      SECTION_TITLES
    end

    def field_required?(field)
      REQUIRED_COLLECTION_FIELDS.include?(field)
    end

    def long_name
      get_column(LONG_NAME_FIELD)
    end

    def short_name
      get_column("ShortName")
    end

    def version_id
      get_column("Version")
    end

    def campaign_from_record_data
      get_column('Projects/ShortName')
    end

    # There is no script yet for UMM collections
    def create_script(raw_data = nil)
      nil
    end

    def evaluate_script(raw_data = nil)
      {}
    end

    def controlled_element_map
      CONTROLLED_ELEMENT_MAP
    end

    def long_name_field
      LONG_NAME_FIELD
    end
  end
end
