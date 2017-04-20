class Dif10Record < Record 
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

  def create_script(raw_data = nil)
    nil 
  end


  def evaluate_script(raw_data = nil)
    nil
  end
end
