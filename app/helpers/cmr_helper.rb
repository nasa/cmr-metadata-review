module CmrHelper
  module ClassMethods

    def flatten_collection(collection_hash, parent_string = "")
      #output will be [['element_name', 'value'], [],....]
      array_collection = flatten_to_array(collection_hash, parent_string)
      #turning into grouped hash
      collection_hash = {}
      bullet = "\u{2022} "
      array_collection.map do |field_name, value|
        value = value.to_s
        if collection_hash.key? field_name
          collection_hash[field_name] += ("\n" + bullet + (value || ""))
        else
          collection_hash[field_name] = (value || "")
        end
        #if field contains bullet but does not start with one, add one to start
        if !collection_hash[field_name].nil? && collection_hash[field_name].include?(bullet)
          #this checks if a bullet symbol (\u{2022}) and a space " " are the two first chars
          if collection_hash[field_name][0..1] != bullet
            collection_hash[field_name] = bullet + collection_hash[field_name]
          end
        end
      end

      collection_hash
    end

    def flatten_to_array(collection_hash, parent_string = "")
      new_collection_arr = []

      collection_hash.each do |key, sub_value|

        if sub_value.is_a?(Hash)
          #flattening the child tree
          flattened_sub_array = flatten_to_array(sub_value, parent_string + "/" + key)
          #adding to flattened parent list
          new_collection_arr.concat(flattened_sub_array)
        elsif sub_value.is_a?(Array)
          #some keyword groupings are presented as lists of strings, do not want to seperate these
          if sub_value[0].is_a?(String)
            #creating an inline object here [key_name, value]
            new_collection_arr_entry = [(parent_string + "/" + key), ""]
            value_index = 1
            sub_value.each_with_index do | array_entry |
              new_collection_arr_entry[value_index] += (array_entry + " ")
            end
            new_collection_arr_entry[value_index].strip
            new_collection_arr.push(new_collection_arr_entry)
          else
            sub_value.each_with_index do | array_entry, index |
              #flattening the child tree
              flattened_sub_array = flatten_to_array(array_entry, parent_string + "/" + key)
              #adding to flattened parent list
              new_collection_arr.concat(flattened_sub_array)
            end
          end
        else
          #if string num or other end value
          new_collection_arr.push([(parent_string + "/" + key), sub_value])
        end
      end

      final_collection_arr = []
      #remove /'s from beginning of every element on top array
      if parent_string == ""
        new_collection_arr.each do |key, sub_value|
          final_collection_arr.push([key[1..-1], sub_value])
        end
      else
        final_collection_arr = new_collection_arr
      end


      return final_collection_arr
    end

  end

  def self.included(receiver)
    receiver.extend ClassMethods
  end

end
