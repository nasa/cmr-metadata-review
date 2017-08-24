module CmrHelper
  module ClassMethods

    def flatten_collection(collection_hash, parent_string = "")
      #output will be [['element_name', 'value'], [],....]
      array_collection = flatten_to_array(collection_hash, parent_string)
      #turning into grouped hash
      collection_hash = {}
      bullet = "\u{2022} "
      array_collection.map do |field_name, value|
        if collection_hash.key? field_name
          collection_hash[field_name] += ("\n" + bullet + (value || ""))
        else
          collection_hash[field_name] = (value || "")
        end  
        #if field contains bullet but does not start with one, add one to start
        if collection_hash[field_name].include?(bullet) 
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


# {"concept_id":"C203234490-LAADS","revision_id":"10","format":"application/echo10+xml","Collection":{"ShortName":"MOD02HKM","VersionId":"6","InsertTime":"2012-07-02T00:00:00.000Z","LastUpdate":"2016-03-09T00:00:00.000Z","LongName":"MODIS/Terra Calibrated Radiances 5-Min L1B Swath 500m V006","DataSetId":"MODIS/Terra Calibrated Radiances 5-Min L1B Swath 500m V006","Description":"The 500 meter MODIS Level 1B data set contains calibrated and geolocated at-aperture radiances for 7 discrete bands located in the 0.45 to 2.20 micron region of the electromagnetic spectrum. These data are generated from the MODIS Level 1A scans of raw radiance and in the process converted to geophysical units of W/(m^2 um sr). In addition, the Earth Bi-directional Reflectance Distribution Function (BRDF) may be determined for these solar reflective bands through knowledge of the solar irradiance (e.g., determined from MODIS solar diffuser data, and from the target illumination geometry).  Additional data are provided including quality flags, error estimates and calibration data.\n\nVisible, shortwave infrared, and near infrared measurements are only made during the daytime, while radiances for the thermal infrared region (bands 20-25, 27-36) are measured continuously.\nChannel locations for the MODIS 500 meter data are as follows:\n            \n            Band   Center Wavelength (um)    Primary Use\n            ----   ----------------------    -----------\n            1          0.620  - 0.670        Land/Cloud Boundaries\n            2          0.841  - 0.876        Land/Cloud Boundaries\n            3          0.459  - 0.479        Land/Cloud Properties\n            4          0.545  - 0.565        Land/Cloud Properties\n            5          1.230  - 1.250        Land/Cloud Properties\n            6          1.628  - 1.652        Land/Cloud Properties\n            7          2.105  - 2.155        Land/Cloud Properties\n            \nChannels 1 and 2 have 250 m resolution, channels 3 through 7 have 500 m resolution. However, for the MODIS L1B 500 m product, the 250 m band radiance data and their associated uncertainties have been aggregated to 500m resolution. Thus the entire channel data set has been co-registered to the same spatial scale in the 500 m product. Separate L1B products are available for the 250 m resolution channels (MOD02QKM) and 1 km resolution channels (MOD021KM). For the latter product, the 250 m and 500 m channel data (bands 1 through 7) have been aggregated into equivalent 1 km pixel values.\n            \nSpatial resolution for pixels at nadir is 500 km, degrading to 2.4 km in the along-scan direction at the scan extremes. However, thanks to the overlapping of consecutive swaths and respectively pixels there, the resulting resolution at the scan extremes is about 1 km. A 55 degree scanning pattern at the EOS orbit of 705 km results in a 2330 km orbital swath width and provides global coverage every one to two days. A single MODIS Level 1B 500 m granule will contain a scene built from 203 scans sampled 2708 times in the cross-track direction, corresponding to approximately 5 minutes worth of data; thus 288 granules will be produced per day. Since an individual MODIS scan will contain 20 along-track spatial elements for the 500 m channels, the scene will be composed of (2708 x 4060) pixels, resulting in a spatial coverage of (2330 km x 2040 km). Due to the MODIS scan geometry, there will be increasing scan overlap beyond about 20 degrees scan angle.      \n\nTo summarize, the MODIS L1B 500 m data product consists of:\n            \n1. Calibrated radiances, uncertainties and number of samples for (2) 250 m reflected solar bands aggregated to 500 m resolution\n            \n2. Calibrated radiances and uncertainties for (5) 500 m reflected solar bands\n            \n3. Geolocation for 1km pixels, that must be interpolated to get 500 m pixel locations. For the relationship of 1km pixels to 500m pixels, see the Geolocation ATBD ttp://modis.gsfc.nasa.gov/data/atbd/atbd_mod28_v3.pdf .\n            \n4. Calibration data for all channels (scale and offset) \n            \n5. Comprehensive set of file-level metadata summarizing the spatial, temporal and parameter attributes of the data, as well as auxiliary information pertaining to instrument status and data quality characterization Users requiring all geolocation and solar/satellite geometry fields at 1km resolution can obtain the separate MODIS Level 1 Geolocation product (MOD03) from LAADS  http://ladsweb.nascom.nasa.gov/ . \n            \nThe Shortname for this product is MOD02HKM and is stored in the Earth Observing System Hierarchical Data Format (HDF-EOS). A typical MOD02HKM file size is approximately 135 MB.\n            \nEnvironmental information derived from MODIS L1B measurements will offer a comprehensive and unprecedented look at terrestrial, atmospheric, and ocean phenomenology for a wide and diverse community of users throughout the world.\n\nSee the MODIS Characterization Support Team webpage for more C6 product information at:\n\nhttp://mcst.gsfc.nasa.gov/l1b/product-information\n\n\nor visit Science Team homepage at:\nhttp://modis.gsfc.nasa.gov/data/dataprod/","CollectionDataType":"SCIENCE_QUALITY","Orderable":"true","Visible":"true","RevisionDate":"2016-03-09T00:00:00.000Z","SuggestedUsage":"Science Research","ProcessingCenter":"NASA/GSFC/SED/ESD/HBSL/BISB/MODAPS","CollectionState":"In Work","SpatialKeywords":{"Keyword":"GLOBAL"},"TemporalKeywords":{"Keyword":"5 minutes"},"Temporal":{"TimeType":"UTC","DateType":"Gregorian","TemporalRangeType":"Continuous Range","PrecisionOfSeconds":"1","RangeDateTime":{"BeginningDateTime":"1999-12-18T00:00:00.000Z"}},"Contacts":{"Contact":[{"Role":"TECHNICAL CONTACT","OrganizationEmails":{"Email":"http://mcst.gsfc.nasa.gov/contact"},"ContactPersons":{"ContactPerson":{"FirstName":"unknown","LastName":"MODIS Characterization Support Team (MCS)"}}},{"Role":"TECHNICAL CONTACT","OrganizationEmails":{"Email":"MODAPSUSO@lists.nasa.gov"},"ContactPersons":{"ContactPerson":{"FirstName":"unknown","LastName":"MODAPS USER SUPPORT TEAM"}}},{"Role":"METADATA AUTHOR","OrganizationEmails":{"Email":"MODAPSUSO@lists.nasa.gov"},"ContactPersons":{"ContactPerson":{"FirstName":"ASAD","LastName":"ULLAH"}}}]},"ScienceKeywords":{"ScienceKeyword":[{"CategoryKeyword":"EARTH SCIENCE","TopicKeyword":"SPECTRAL/ENGINEERING","TermKeyword":"INFRARED WAVELENGTHS","VariableLevel1Keyword":{"Value":"INFRARED RADIANCE"}},{"CategoryKeyword":"EARTH SCIENCE","TopicKeyword":"SPECTRAL/ENGINEERING","TermKeyword":"INFRARED WAVELENGTHS","VariableLevel1Keyword":{"Value":"REFLECTED INFRARED"}},{"CategoryKeyword":"EARTH SCIENCE","TopicKeyword":"SPECTRAL/ENGINEERING","TermKeyword":"VISIBLE WAVELENGTHS","VariableLevel1Keyword":{"Value":"VISIBLE RADIANCE"}}]},"Platforms":{"Platform":{"ShortName":"TERRA","LongName":"Earth Observing System, TERRA (AM-1)","Type":"Earth Observation Satellites","Characteristics":{"Characteristic":{"Name":"EquatorCrossingTime","Description":"Local time of the equator crossing and direction (ascending or descending)","DataType":"Time/direction (descending)","Unit":"Local Mean Time","Value":"10:30, descending"}},"Instruments":{"Instrument":{"ShortName":"MODIS","LongName":"Moderate-Resolution Imaging Spectroradiometer","Technique":"Imaging Spectroradiometry","Sensors":{"Sensor":{"ShortName":"MODIS","LongName":"Cross-track Scanning Radiometer","Technique":"Radiometry"}}}}}},"AdditionalAttributes":{"AdditionalAttribute":[{"Name":"SCI_ABNORM","DataType":"INT","Description":"Flag set (to 0) if science_abnormal, the L1A engineering data ground-set flag that indicates potentially abnormal science data due to things other than MODIS (such as maneuvers, data link, etc.), was set for at least one scan in the granule."},{"Name":"VeryHighConfidentClearPct","DataType":"FLOAT","Description":"None"},{"Name":"SuccessfulRetrievalPct_Land","DataType":"FLOAT","Description":"None"},{"Name":"SuccessfulRetrievalPct_Ocean","DataType":"FLOAT","Description":"None"},{"Name":"SuccessfulRetrievalPct_IR","DataType":"FLOAT","Description":"None"},{"Name":"SuccessfulRetrievalPct_NIR","DataType":"FLOAT","Description":"None"},{"Name":"CloudCoverFractionPct_VIS","DataType":"FLOAT","Description":"None"},{"Name":"IceCloudDetectedPct_VIS","DataType":"FLOAT","Description":"None"},{"Name":"SuccessCloudOptPropRtrPct_VIS","DataType":"FLOAT","Description":"None"},{"Name":"SuccessCloudPhaseRtrPct_IR","DataType":"FLOAT","Description":"None"},{"Name":"SuccessCloudTopPropRtrPct_IR","DataType":"FLOAT","Description":"None"},{"Name":"SuccessfulRetrievalPct","DataType":"FLOAT","Description":"None"},{"Name":"ClearPct250m","DataType":"FLOAT","Description":"None"},{"Name":"CloudCoverPct250m","DataType":"FLOAT","Description":"None"},{"Name":"HighConfidentClearPct","DataType":"FLOAT","Description":"None"},{"Name":"LowConfidentClearPct","DataType":"FLOAT","Description":"None"},{"Name":"SCI_STATE","DataType":"INT","Description":"Flag set (to 0) if science_state, the L1A engineering data flag that indicates the Normal/Test configuration of the MODIS instrument, was set for at least one scan in the granule."}]},"Campaigns":{"Campaign":[{"ShortName":"EOSDIS","LongName":"Earth Observing System Data Information System"},{"ShortName":"ESIP","LongName":"Earth Science Information Partners Program"},{"ShortName":"TERRA","LongName":"Earth Observing System (EOS), TERRA"}]},"OnlineAccessURLs":{"OnlineAccessURL":[{"URL":"https://ladsweb.nascom.nasa.gov/data/search.html","URLDescription":"Search and order products from LAADS website."},{"URL":"ftp://ladsweb.nascom.nasa.gov/allData/6/MOD02HKM/","URLDescription":"Direct access to the ftp site and directory hosting the MOD02HKM 6 data set."}]},"OnlineResources":{"OnlineResource":[{"URL":"http://modaps.nascom.nasa.gov/services/about/product_descriptions_terra.html","Description":"Overview of MODIS","Type":"USER SUPPORT"},{"URL":"http://mcst.gsfc.nasa.gov/l1b/product-information","Description":"MODIS Level 1B Product Information Page at MCST","Type":"USER SUPPORT"}]},"Spatial":{"HorizontalSpatialDomain":{"Geometry":{"CoordinateSystem":"CARTESIAN","BoundingRectangle":{"WestBoundingCoordinate":"-180","NorthBoundingCoordinate":"90","EastBoundingCoordinate":"180","SouthBoundingCoordinate":"-90"}}},"GranuleSpatialRepresentation":"GEODETIC"}}}