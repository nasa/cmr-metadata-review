#RecordFormats are modules to be included in record objects upon initialization
#
#Since individual record formats have different underlying structures of RecordData objects
#unique accessors are needed for each format to access commonly requested data.
module RecordFormats::Dif10Record
  SECTION_TITLES = ["Platform", "Science_Keywords", "Dataset_Citation", "Organization", "Personnel", "Related_URL", "Additional_Attributes", "Temporal_Coverage", "Spatial_Coverage", "Project", "Metadata_Dates"]

  include RecordFormats::Dif10ControlledElements

  def get_section_titles
    SECTION_TITLES
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

  #There is currently no script for DIF10 records
  def create_script(raw_data = nil)
    nil 
  end

  #There is currently no script for DIF10 records
  def evaluate_script(raw_data = nil)
    nil
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
