#RecordFormats are modules to be included in record objects upon initialization
#
#Since individual record formats have different underlying structures of RecordData objects
#unique accessors are needed for each format to access commonly requested data.
module RecordFormats
  module Dif10Record
    SECTION_TITLES = ["Summary", "Platform", "Science_Keywords", "Dataset_Citation", "Organization", "Personnel", "Reference", "Location", "Data_Resolution", "Related_URL", "Distribution", "Multimedia_Sample", "Additional_Attributes", "Temporal_Coverage", "Spatial_Coverage", "Project", "Metadata_Dates"]
    GRANULE_SECTION_TITLES = []

    include RecordFormats::Dif10ControlledElements

    def get_section_titles
      collection? ? SECTION_TITLES : GRANULE_SECTION_TITLES
    end

    # ====Params
    # None
    # ====Returns
    # String
    # ==== Method
    # Accesses the record's RecordData attribute and then returns the value of the "LongName" (equivalent) field
    def long_name
      self.get_column("Entry_Title")
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
      #escaping json for passing to python
      record_json = raw_data.to_json.gsub("\"", "\\\"")
      #running collection script in python
      #W option to silence warnings
      if collection?
        script_results = `python -W ignore lib/CollectionCheckerDIF.py "#{record_json}"  `
      else
        script_results = nil
      end

      unless script_results.nil?
        comment_hash = JSON.parse(script_results)
        value_keys = self.record_datas.map { |data| data.column_name }
        comment_hash = Record.format_script_comments(comment_hash, value_keys)
        comment_hash
      else
        {}
      end
    end

    def controlled_notice_list(element_list)
      controlled_map = {}
      element_list.map do |element|
        if CONTROLLED_ELEMENT_MAP.key? element
          controlled_map[element] = CONTROLLED_ELEMENT_MAP[element]
        end
      end
      controlled_map
    end
  end
end
