#RecordFormats are modules to be included in record objects upon initialization
#
#Since individual record formats have different underlying structures of RecordData objects
#unique accessors are needed for each format to access commonly requested data.
module Modules::RecordFormats::Dif10Record
  SECTION_TITLES = ["Summary", "Platform", "Science_Keywords", "Dataset_Citation", "Organization", "Personnel", "Reference", "Location", "Data_Resolution", "Related_URL", "Distribution", "Multimedia_Sample", "Additional_Attributes", "Temporal_Coverage", "Spatial_Coverage", "Project", "Metadata_Dates"]
  GRANULE_SECTION_TITLES = []

  include Modules::RecordFormats::Dif10ControlledElements

  def get_section_titles
    if self.is_collection?
      SECTION_TITLES
    else
      GRANULE_SECTION_TITLES
    end
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