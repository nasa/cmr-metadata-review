# RecordFormats are modules to be included in record objects upon initialization
#
# Since individual record formats have different underlying structures of RecordData objects
# unique accessors are needed for each format to access commonly requested data.
module RecordFormats
  module Dif10Record
    include RecordFormats::Dif10Fields

    LONG_NAME_FIELD = "Entry_Title"

    def get_section_titles
      SECTION_TITLES
    end

    def field_required?(field)
      REQUIRED_COLLECTION_FIELDS.include?(field)
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

    # There are currently only scripts for DIF10 collections.
    def create_script(raw_data = nil)
      if raw_data.nil?
        raw_data = get_raw_data
      end
      comment_hash = self.evaluate_script(raw_data)
      score = score_script_hash(comment_hash)
      add_script_comment(comment_hash)
    end

    # There are currently only scripts for DIF10 collections.
    def evaluate_script(raw_data = nil)
      if raw_data.nil?
        raw_data = get_raw_data
      end
      raw_data.each { |key, value|
        if value.instance_of? String
          value.gsub!('"', '')
        end
      }
      #escaping json for passing to python
      # https://stackoverflow.com/questions/28356308/escaping-single-quotes-for-shell
      record_json = raw_data.to_json
      record_json.gsub!("'", "'\\\\''")
      #running collection script in python
      #W option to silence warnings
      if collection?
        script_results = `python -W ignore lib/CollectionCheckerDIF.py '#{record_json}'  `
      else
        script_results = nil
      end

      unless script_results.to_s.empty?
        comment_hash = JSON.parse(script_results)
        value_keys = self.record_datas.map { |data| data.column_name }
        comment_hash = Record.format_script_comments(comment_hash, value_keys)
        comment_hash
      else
        Rails.logger.error("Python error occurred DIF10 (#{short_name})")
        raise Errors::PythonError
      end
    end

    def long_name_field
      LONG_NAME_FIELD
    end

    def controlled_element_map
      CONTROLLED_ELEMENT_MAP
    end
  end
end
