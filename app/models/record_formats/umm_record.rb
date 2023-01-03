# RecordFormats are modules to be included in record objects upon initialization
#
# Since individual record formats have different underlying structures of RecordData objects
# unique accessors are needed for each format to access commonly requested data.
module RecordFormats
  module UmmRecord

    LONG_NAME_FIELD = "EntryTitle"

    def get_section_titles
      SectionTitles.instance.get_format_fields('ummc')
    end

    def field_required?(field)
      RequiredFields.instance.get_format_fields('ummc').include?(field)
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

    def create_script
      comment_hash = self.evaluate_script()
      add_script_comment(comment_hash)
    end

    def get_raw_concept(concept_id, format)
      url = "#{Cmr.get_cmr_base_url}/search/concepts/#{concept_id}.#{format}"
      raw_data = Cmr.cmr_request(url).parsed_response
      raw_data
    end

    def evaluate_script(raw_data = nil)
      if raw_data.nil?
        raw_data = get_raw_concept(concept_id, "umm_json")
      end
      script_results = Quarc.instance.validate('umm-c', raw_data)
      script_results = script_results.to_json

      unless script_results.to_s.empty?
        comment_hash = JSON.parse(script_results)
        value_keys = self.record_datas.map { |data| data.column_name }
        comment_hash = Record.format_script_comments(comment_hash, value_keys)
        comment_hash
      else
        raise Errors::PyQuARCError, "PyQuARC error occurred UMM-C (#{short_name})"
      end
    end

    def controlled_element_map
      ControlledElements.instance.mapping("umm_json")
    end

    def long_name_field
      LONG_NAME_FIELD
    end
  end
end
