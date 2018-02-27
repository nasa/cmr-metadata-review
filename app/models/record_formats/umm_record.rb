# RecordFormats are modules to be included in record objects upon initialization
#
# Since individual record formats have different underlying structures of RecordData objects
# unique accessors are needed for each format to access commonly requested data.
module RecordFormats
  module UmmRecord
    include RecordFormats::UmmControlledElements

    def long_name
      get_column("EntryTitle")
    end

    def short_name
      get_column("ShortName")
    end

    def version_id
      get_column("Version")
    end

    # There is no script yet for UMM collections
    def create_script(raw_data = nil)
      nil
    end

    def evaluate_script(raw_data = nil)
      {}
    end

    def controlled_notice_list(element_list)
      {}.tap do |controlled_map|
        element_list.each do |element|
          controlled_map[element] = CONTROLLED_ELEMENT_MAP[element] if CONTROLLED_ELEMENT_MAP.key?(element)
        end
      end
    end
  end
end
