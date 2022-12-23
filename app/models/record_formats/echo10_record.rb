# RecordFormats are modules to be included in record objects upon initialization
#
# Since individual record formats have different underlying structures of RecordData objects
# unique accessors are needed for each format to access commonly requested data.
module RecordFormats
  module Echo10Record
    include RecordHelper

    LONG_NAME_FIELD = "LongName"

    def get_section_titles
      collection? ? SectionTitles.instance.get_format_fields('echo10') : SectionTitles.instance.get_format_fields('echo10_granule')
    end

    def field_required?(field)
      required_fields.include?(field)
    end

    # ====Params
    # None
    # ====Returns
    # String
    # ==== Method
    # Accesses the record's RecordData attribute and then returns the value of the "LongName" field
    def long_name
      if collection?
        get_column(LONG_NAME_FIELD)
      else
        get_column("GranuleUR")
      end
    end

    # ====Params
    # None
    # ====Returns
    # String
    # ==== Method
    # Accesses the record's RecordData attribute and then returns the value of the "ShortName" field
    def short_name
      self.get_column("ShortName")
    end

    # ====Params
    # None
    # ====Returns
    # String
    # ==== Method
    # Accesses the record's RecordData attribute and then returns the value of the "VersionId" field
    def version_id
      self.get_column("VersionId")
    end

    def campaign_from_record_data
      get_column('Campaigns/Campaign/ShortName')
    end

    def create_script
      comment_hash = self.evaluate_script()
      add_script_comment(comment_hash)
    end

    # ====Params
    # optional Hash
    # ====Returns
    # Hash
    # ==== Method
    # This method runs the automated script against a record and then saves the result in a new ScriptComment object
    # The script is run through a shell command which accesses the python scripts in the /lib directory.
    # Parameter is optional hash of raw metadata from cmr for one record, if not provided, the raw data is manually retreived
    # Returns a formatted hash with results from script as values for each record field as keys.

    def get_raw_concept(concept_id, format)
      url = "#{Cmr.get_cmr_base_url}/search/concepts/#{concept_id}.#{format}"
      raw_data = Cmr.cmr_request(url).parsed_response
      raw_data
    end

    def evaluate_script(raw_data = nil)
      if raw_data.nil?
        raw_data = get_raw_concept(concept_id, "echo10")
      end
      validation_type = collection? ? 'echo-c' : 'echo-g'
      script_results = Quarc.instance.validate(validation_type, raw_data)
      script_results = script_results.to_json

      unless script_results.to_s.empty?
        comment_hash = JSON.parse(script_results)
        value_keys = self.record_datas.map { |data| data.column_name }
        comment_hash = Record.format_script_comments(comment_hash, value_keys)
        comment_hash
      else
        if (collection?)
          identifier = "Collection #{short_name} #{version_id}"
        else
          identifier = "Granule #{self.get_column("GranuleUR")}"
        end
        raise Errors::PyQuARCError, "PyQuARC error occurred (#{identifier})"
      end
    end

    def controlled_element_map
      ControlledElements.instance.mapping("echo10")
    end

    def long_name_field
      LONG_NAME_FIELD
    end

    private

    def required_fields
      @required_fields ||= collection? ? RequiredFields.instance.get_format_fields('echo10') : RequiredFields.instance.get_format_fields('echo10_granule')
    end
  end
end
