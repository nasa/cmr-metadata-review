module DocumentAmendmentsHelper
  module ClassMethods

    #
    # public methods
    #

    def assign_not_available_values(data_format, collection)
      collection = JSON.load(collection.to_json).to_hash
      collection = assign_not_available_to_science_keywords(data_format, collection)
      collection = assign_not_available_to_location_keywords(data_format, collection)
      return collection
    end

    #
    # private methods
    #

    # This utility function will dig down into a nested hash and assign the "N/A" if the value doesn't exist.
    #
    def dig_and_set_na(parent, stack)
      return if (stack.length == 0)
      if parent.is_a?(Array)
        parent.each do |item|
          dig_and_set_na(item, stack.dup)
        end
      else
        if parent.is_a?(Hash)
          field = stack.shift()
          value = parent[field]
          if value.nil?
            value = stack.length == 0 ? 'N/A' : {}
            parent[field] = value
          end
          dig_and_set_na(parent[field], stack.dup)
        end
      end
    end

    def assign_not_available_to_science_keywords(data_format, collection)
      keys = []
      if (data_format == 'echo10')
        keys = [
          ["ScienceKeywords", "ScienceKeyword", "CategoryKeyword"],
          ["ScienceKeywords", "ScienceKeyword", "TopicKeyword"],
          ["ScienceKeywords", "ScienceKeyword", "TermKeyword"],
          ["ScienceKeywords", "ScienceKeyword", "VariableLevel1Keyword", "Value"],
          ["ScienceKeywords", "ScienceKeyword", "VariableLevel1Keyword", "VariableLevel2Keyword", "Value"],
          ["ScienceKeywords", "ScienceKeyword", "VariableLevel1Keyword", "VariableLevel2Keyword", "VariableLevel3Keyword", "Value"],
          ["ScienceKeywords", "ScienceKeyword", "DetailedVariableKeyword"],
        ]
      end
      if (data_format == 'dif10')
        keys = [
          ["Science_Keywords", "Category"],
          ["Science_Keywords", "Topic"],
          ["Science_Keywords", "Term"],
          ["Science_Keywords", "Variable_Level_1"],
          ["Science_Keywords", "Variable_Level_2"],
          ["Science_Keywords", "Variable_Level_3"],
          ["Science_Keywords", "Detailed_Variable"]
        ]
      end
      if (data_format == 'umm_json')
        keys = [
          ["ScienceKeywords", "Category"],
          ["ScienceKeywords", "Topic"],
          ["ScienceKeywords", "Term"],
          ["ScienceKeywords", "VariableLevel1"],
          ["ScienceKeywords", "VariableLevel2"],
          ["ScienceKeywords", "VariableLevel3"],
          ["ScienceKeywords", "DetailedVariable"]
        ]
      end

      keys.each do |path|
        dig_and_set_na(collection, path)
      end

      return collection
    end

    def assign_not_available_to_location_keywords(data_format, collection)
      if (data_format == 'dif10')
        keys = [
          ["Location", "Location_Category"],
          ["Location", "Location_Type"],
          ["Location", "Location_Subregion1"],
          ["Location", "Location_Subregion2"],
          ["Location", "Location_Subregion3"],
          ["Location", "Detailed_Location"],
        ]
        unless collection.dig("Location").nil?
          keys.each do |path|
            dig_and_set_na(collection, path)
          end
        end
      end
      if (data_format == 'umm_json')
        keys = [
          ["LocationKeywords", "Category"],
          ["LocationKeywords", "Type"],
          ["LocationKeywords", "Subregion1"],
          ["LocationKeywords", "Subregion2"],
          ["LocationKeywords", "Subregion3"],
          ["LocationKeywords", "DetailedLocation"],
        ]
        unless collection.dig("LocationKeywords").nil?
          keys.each do |path|
            dig_and_set_na(collection, path)
          end
        end
      end
      return collection
    end
  end

  def self.included(receiver)
    receiver.extend ClassMethods
  end

end

