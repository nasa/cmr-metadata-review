# RecordFormats are modules to be included in record objects upon initialization
#
# Since individual record formats have different underlying structures of RecordData objects
# unique accessors are needed for each format to access commonly requested data.
module RecordFormats
  module Dif10Record
    include RecordHelper

    LONG_NAME_FIELD = "Entry_Title"

    def get_section_titles
      SectionTitles.instance.get_format_fields('dif10')
    end

    def field_required?(field)
      RequiredFields.instance.get_format_fields('dif10').include?(field)
    end

    # ====Params
    # None
    # ====Returns
    # String
    # ==== Method
    def long_name
      self.get_column(LONG_NAME_FIELD)
    end

    # ====Params
    # None
    # ====Returns
    # String
    # ==== Method
    # Accesses the record's RecordData attribute and then returns the value of the "ShortName" (equivalent) field
    def short_name
      self.get_column("Entry_ID/Short_Name")
    end

    # ====Params
    # None
    # ====Returns
    # String
    # ==== Method
    # Accesses the record's RecordData attribute and then returns the value of the "VersionId" (equivalent) field
    def version_id
      self.get_column("Entry_ID/Version")
    end

    def campaign_from_record_data
      get_column('Project/Short_Name')
    end

    # There are currently only scripts for DIF10 collections.
    def create_script(raw_data = nil)
      if raw_data.nil?
        raw_data = get_raw_data('dif10')
      end
      comment_hash = self.evaluate_script(raw_data)
      score = score_script_hash(comment_hash)
      add_script_comment(comment_hash)
    end

    def get_raw_concept(concept_id, format)
      url = "#{Cmr.get_cmr_base_url}/search/concepts/#{concept_id}.#{format}"
      raw_data = Cmr.cmr_request(url).parsed_response
      raw_data
    end

    # There are currently only scripts for DIF10 collections.
    def evaluate_script(raw_data = nil)
      raw_data = get_raw_concept(concept_id, "dif10")
      script_results = ''
      if collection?
        Tempfile.create do |file|
          file << raw_data
          file.flush
          output = `lib/dashboard_checker.sh #{file.path} dif10`
          Rails.logger.info("Results of running dashboard checker for #{short_name}: #{output}")
          script_results = File.read(file.path+'.out')
          File.delete(file.path+'.out')
        end
      end

      unless script_results.to_s.empty?
        comment_hash = JSON.parse(script_results)
        value_keys = self.record_datas.map { |data| data.column_name }
        comment_hash = Record.format_script_comments(comment_hash, value_keys)
        comment_hash
      else
        raise Errors::PythonError, "Python error occurred DIF10 (#{short_name})"
      end
    end

    def long_name_field
      LONG_NAME_FIELD
    end

    def controlled_element_map
      ControlledElements.instance.mapping("dif10")
    end
  end
end
