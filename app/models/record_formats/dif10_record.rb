#RecordFormats are modules to be included in record objects upon initialization
#
#Since individual record formats have different underlying structures of RecordData objects
#unique accessors are needed for each format to access commonly requested data.
module RecordFormats::Dif10Record
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

  #should return a list where each entry is a (title,[title_list])
  def sections
    section_list = []
    platform = self.get_section("Platform")
    science_keywords = self.get_section("Science_Keywords")
    organization = self.get_section("Organization")
    personnel = self.get_section("Personnel")
    related_url = self.get_section("Related_URL")
    additional = self.get_section("Additional_Attributes")

    section_list = section_list + platform + science_keywords + organization + personnel + related_url + additional

    used_titles = (section_list.map {|section| section[1]}).flatten
    all_titles = self.record_datas.map { |data| data.column_name }

    others = [["Collection Info", all_titles.select {|title| !used_titles.include? title }]]

    section_list = others + section_list
  end

  #There is currently no script for DIF10 records
  def create_script(raw_data = nil)
    nil 
  end

  #There is currently no script for DIF10 records
  def evaluate_script(raw_data = nil)
    nil
  end
end
