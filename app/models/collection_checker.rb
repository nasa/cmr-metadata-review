class CollectionChecker 
# '''
# Copyright 2016, United States Government, as represented by the Administrator of 
# the National Aeronautics and Space Administration. All rights reserved.
# The “pyCMR” platform is licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. You may obtain a 
# copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
 
# Unless required by applicable law or agreed to in writing, software distributed under 
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF 
# ANY KIND, either express or implied. See the License for the specific language 
# governing permissions and limitations under the License.
# '''

# import csv
# import urllib2
# import socket
# from collections import defaultdict
# from datetime import *

require 'csv'

# LocationKeywordURL = "http://gcmdservices.gsfc.nasa.gov/static/kms/locations/locations.csv"
LocationKeywordURL = "http://gcmdservices.gsfc.nasa.gov/static/kms/locations/locations.json"
ScienceKeywordURL = "http://gcmdservices.gsfc.nasa.gov/static/kms/sciencekeywords/sciencekeywords.json"
PlatformURL = "http://gcmdservices.gsfc.nasa.gov/static/kms/platforms/platforms.json"
InstrumentURL = "http://gcmdservices.gsfc.nasa.gov/static/kms/instruments/instruments.json"
ProjectURL = "http://gcmdservices.gsfc.nasa.gov/static/kms/projects/projects.json"
ResourcesTypeURL = "http://gcmdservices.gsfc.nasa.gov/static/kms/rucontenttype/rucontenttype.json"
ArchtoURLs = {'SEDAC':'http://sedac.ciesin.columbia.edu/data/set/', 
            'GHRC':'https://fcportal.nsstc.nasa.gov/pub',
            'NSIDC':'http://nsidc.org/data/',
            'LPDAAC':'https://lpdaac.usgs.gov/node/',
            'ORNL_DAAC':'http://daac.ornl.gov/cgi-bin/dsviewer.pl?ds_id',
            'OB.DAAC':'http://oceandata.sci.gsfc.nasa.gov/',
            'Alaska Satellite Facility':'https://vertex.daac.asf.alaska.edu/'}

    def checkAll(metadata)
        #a hash to be converted to JSON to store as a review comment
        script_results = {}
        result = ""

        checkShortName(metadata, script_results)

        # result += self.checkShortName(metadata['ShortName']) + ', '

        checkVersionID(metadata, script_results)
        # result += self.checkVersionID(metadata['VersionId']) + ', '

        checkInsertTime(metadata, script_results)
        # ================
        # try:
        #     result += self.checkInsertTime(metadata['InsertTime']) + ', '
        # except KeyError:
        #     result += "np - Please provide an insert time for this dataset. This is a required field." + ', '
        # # ================
        checkLastUpdate(metadata, script_results)

        # try:
        #     result += self.checkLastUpdate(metadata['LastUpdate']) + ', '
        # except KeyError:
        #     result += "np - Please provide an last update time for this dataset. This is a required field." + ', '
        # ================

        checkLongName(metadata, script_results)

        # try:
        #     result += self.checkLongName(metadata['LongName']) + ', '
        # except KeyError:
        #     result += "np" + ', '
        # ================

        checkCollectionState(metadata, script_results)

        # try:
        #     result += self.checkCollectionState(metadata['CollectionState']) + ', , '
        # except KeyError:
        #     result += "np" + ', , '

        checkDataSetID(metadata, script_results)

        # result += self.checkDateSetID(metadata['DataSetId']) + ', '
        # ================

        checkDesc(metadata, script_results)

        # try:
        #     result += self.checkDesc(metadata['Description']) + ', , , '
        # except KeyError:
        #     result += "np - Please provide an abstract for this dataset." + ', , , '
        # ================
        
        checkProcLevelID(metadata, script_results)

        # try:
        #     result += self.checkProcLevelID(metadata['ProcessingLevelId']) + ', , '
        # except KeyError:
        #     result += "np - Please provide a processing level Id for this dataset. This is a required field." + ', , '
        # # ================

        checkArchiveCenter(metadata, script_results)

        # try:
        #     metadata['ArchiveCenter']
        #     try:
        #         result += self.checkArchiveCenter(metadata['ArchiveCenter'], metadata['ProcessingCenter']) + ', , , , , '
        #     except KeyError:
        #         result += self.checkArchiveCenter(metadata['ArchiveCenter'], None) + ', , , , , '
        # except KeyError:
        #     result += "np - Please provide an archive center for this dataset." + ', , , , , '
        # ================
        checkDateFormat(metadata, script_results)

        # try:
        #     result += self.checkDateFormat(metadata['DataFormat']) + ', , '
        # except KeyError:
        #     result += "np - Recommend providing data format." + ', , '
        # ================
        checkSpatialKey(metadata, script_results)

        # try:
        #     result += self.checkSpatialKey(metadata['SpatialKeywords']['Keyword']) + ', '
        # except KeyError:
        #     result += "np" + ', '
        # ================
        checkTemporalKeyword(metadata, script_results)

        # try:
        #     result += self.checkTemporalKeyword(metadata['TemporalKeywords']['Keyword'], 1) + ', , , , , , '
        # except KeyError:
        #     if metadata['TemporalKeywords'] != None:
        #         length = len(metadata['TemporalKeywords'])
        #         result += self.checkTemporalKeyword(metadata['TemporalKeywords'], length) + ', , , , , , '
        #     else:
        #         result += 'np' + ', , , , , , '
        # ================

        checkBeginDateTime(metadata, script_results)

        # try:
        #     result += self.checkBeginDateTime(metadata['Temporal']['RangeDateTime']['BeginningDateTime']) + ', '
        # except KeyError:
        #     result += "Check for single date time or periodic date time fields" + ', '
        # ================

        checkEndDateTime(metadata, script_results)

        try:
            result += self.checkEndDateTime(metadata['Temporal']['RangeDateTime']['EndingDateTime']) + ', '
        except KeyError:
            result += "Check for single date time or periodic date time fields" + ', '    
        # ================
        checkContactRole(metadata, script_results)

        # result += self.checkContactRole(metadata['Contacts']['Contact']['Role']) + ', , , ,'
        # ================
        checkContactEmail(metadata, script_results)

        # try:
        #     result += self.checkContactEmail(metadata['Contacts']['Contact']['OrganizationEmails']['Email'], 1) + ', , , , , , , , , , , , '
        # except KeyError:
        #     if metadata['Contacts']['Contact']['OrganizationEmails'] != None:
        #         length = len(metadata['Contacts']['Contact']['OrganizationEmails'])
        #         result += self.checkContactEmail(metadata['Contacts']['Contact']['OrganizationEmails'], length) + ', , , , , , , , , , , , '
        #     else:
        #         result += "np" + ', , , , , , , , , , , , '
        # ================
        checkSciKeyCategory(metadata, script_results)

        # try:
        #     result += self.checkSciKeyCategory(metadata['ScienceKeywords']['ScienceKeyword']['CategoryKeyword'], 1) + ', '
        # except TypeError:
        #     if metadata['ScienceKeywords'] != None:
        #         length = len(metadata['ScienceKeywords']['ScienceKeyword'])
        #         result += self.checkSciKeyCategory(metadata['ScienceKeywords']['ScienceKeyword'], length) + ', '
        #     else:
        #         result += "np - Please provide at least one science category keyword for this dataset. This is a required field." + ', '
        # except KeyError:
        #     result += "np - Please provide at least one science category keyword for this dataset. This is a required field." + ', '
        # ================

        checkSciKeyTopic(metadata, script_results)

        # try:
        #     result += self.checkSciKeyTopic(metadata['ScienceKeywords']['ScienceKeyword']['TopicKeyword'], 1) + ', '
        # except TypeError:
        #     if metadata['ScienceKeywords'] != None:
        #         length = len(metadata['ScienceKeywords']['ScienceKeyword'])
        #         result += self.checkSciKeyTopic(metadata['ScienceKeywords']['ScienceKeyword'], length) + ', '
        #     else:
        #         result += "np - Please provide at least one science topic keyword for this dataset. This is a required field." + ', '
        # except KeyError:
        #     result += "np - Please provide at least one science topic keyword for this dataset. This is a required field." + ', '
        # ================

        checkSciKeyTerm(metadata, script_results)

        # try:
        #     result += self.checkSciKeyTerm(metadata['ScienceKeywords']['ScienceKeyword']['TermKeyword'], 1) + ', '
        # except TypeError:
        #     if metadata['ScienceKeywords'] != None:
        #         length = len(metadata['ScienceKeywords']['ScienceKeyword'])
        #         result += self.checkSciKeyTerm(metadata['ScienceKeywords']['ScienceKeyword'], length) + ', '
        #     else:
        #         result += "np - Please provide at least one science term keyword for this dataset. This is a required field." + ', '
        # except KeyError:
        #     result += "np - Please provide at least one science term keyword for this dataset. This is a required field." + ', '
        # ================

        checkSciKeyVarL1(metadata, script_results)

        # try:
        #     result += self.checkSciKeyVarL1(metadata['ScienceKeywords']['ScienceKeyword']['VariableLevel1Keyword']['Value'], 1) + ', , , ,  '
        # except TypeError:
        #     if metadata['ScienceKeywords'] != None:
        #         length = len(metadata['ScienceKeywords']['ScienceKeyword'])
        #         result += self.checkSciKeyVarL1(metadata['ScienceKeywords']['ScienceKeyword'], length) + ',  , , , '
        #     else:
        #         result += "np" + ', , , , '
        # except KeyError:
        #     result += "np" + ', , , , '
        # ================

        checkPlatformShortName(metadata, script_results)

        # try:
        #     result += self.checkPlatformShortName(metadata['Platforms']['Platform']['ShortName'], 1) + ', , '
        # except TypeError:
        #     if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
        #         length = len(metadata['Platforms']['Platform'])
        #         result += self.checkPlatformShortName(metadata['Platforms']['Platform'], length) + ', , '
        #     else:
        #         result += "np - Please provide at least one platform for this dataset. This is a required field." + ', , '
        # except KeyError:
        #     result += "np - Please provide at least one platform for this dataset. This is a required field." + ', , '
        # ================
        try:
            metadata['Platforms']['Platform']['Type']
            result += self.checkPlatformType(metadata['Platforms']['Platform']['Type'], 1) + ', , , , , , '
        except TypeError:
            if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                length = len(metadata['Platforms']['Platform'])
                result += self.checkPlatformType(metadata['Platforms']['Platform'], length) + ', , , , , , '
            else:
                pass
        except KeyError:
                # According to spec, not need to handle this case.
                pass
        # ================
        try:
            metadata['Platforms']['Platform']['ShortName']
            platform_num = 1
            result += self.checkInstrShortName(metadata['Platforms']['Platform'], platform_num) + ', , , , , , , , , , , , , , , , , , , , , , , , , , , , , , ,'
        except TypeError:
            if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                platform_num = len(metadata['Platforms']['Platform'])
                result += self.checkInstrShortName(metadata['Platforms']['Platform'], platform_num) + ', , , , , , , , , , , , , , , , , , , , , , , , , , , , , , ,'
            else:
                result += "np - Please provide at least one instrument relevant to the platform provided for this dataset. This is a required field." + ', , , , , , , , , , , , , , , , , , , , , , , , , , , , , , ,'
        except KeyError:
            result += "np - Please provide at least one instrument relevant to the platform provided for this dataset. This is a required field." + ', , , , , , , , , , , , , , , , , , , , , , , , , , , , , , ,'
        # ================
        try:
            result += self.checkCampaignShortName(metadata['Campaigns']['Campaign']['ShortName'], 1) + ', , , , , , , , , '
        except TypeError:
            length = len(metadata['Campaigns']['Campaign'])
            result += self.checkCampaignShortName(metadata['Campaigns']['Campaign'], length) + ', , , , , , , , , '
        except KeyError:
            result += "np - Please provide a campaign name for this dataset. This is a required field." + ', , , , , , , , , '
        # ================
        try:
            result += self.checkOnlineAccessURL(metadata['OnlineAccessURLs']['OnlineAccessURL']['URL'], 1, metadata['ArchiveCenter']) + ','
        except TypeError:
            if metadata['OnlineAccessURLs'] != None:
                length = len(metadata['OnlineAccessURLs']['OnlineAccessURL'])
                result += self.checkOnlineAccessURL(metadata['OnlineAccessURLs']['OnlineAccessURL'], length, metadata['ArchiveCenter']) + ','
            else:
                result += "np - Please provide at least one online access URL for this dataset." + ','
        except KeyError:
            result += "np - Please provide at least one online access URL for this dataset." + ','
        # ================
        try:
            result += self.checkOnlineURLDesc(metadata['OnlineAccessURLs']['OnlineAccessURL']['Description'], 1) + ', ,'
        except TypeError:
            if metadata['OnlineAccessURLs'] != None:
                length = len(metadata['OnlineAccessURLs']['OnlineAccessURL'])
                result += self.checkOnlineURLDesc(metadata['OnlineAccessURLs']['OnlineAccessURL'], length) + ', ,'
            else:
                result += "Recommend adding a brief URL Description." + ', , '
        except KeyError:
            result += "Recommend adding a brief URL Description" + ', ,'
        # ================
        try:
            result += self.checkOnlineResourceURL(metadata['OnlineResources']['OnlineResource']['URL'], 1) + ','
        except TypeError:
            if metadata['OnlineResources'] != None:
                length = len(metadata['OnlineResources']['OnlineResource'])
                result += self.checkOnlineResourceURL(metadata['OnlineResources']['OnlineResource'], length) + ','
            else:
                result += "np" + ','
        except KeyError:
            result += "np" + ','
        # ================
        try:
            result += self.checkOnlineResourceURLDesc(metadata['OnlineResources']['OnlineResource']['Description'], 1) + ','
        except TypeError:
            if metadata['OnlineResources'] != None:
                length = len(metadata['OnlineResources']['OnlineResource'])
                result += self.checkOnlineResourceURLDesc(metadata['OnlineResources']['OnlineResource'], length) + ','
            else:
                result += "np" + ','
        except KeyError:
            result += "np" + ','
        # ================
        try:
            result += self.checkOnlineResourceType(metadata['OnlineResources']['OnlineResource']['Type'], 1) + ', , , , '
        except TypeError:
            if metadata['OnlineResources'] != None:
                length = len(metadata['OnlineResources']['OnlineResource'])
                result += self.checkOnlineResourceType(metadata['OnlineResources']['OnlineResource'], length) + ', , , , '
            else:
                result += "np" + ', , , , '
        except KeyError:
            result += "np" + ', , , , '
        # ================
        result += self.checkSpatialHorGeoCoor(metadata['Spatial']['HorizontalSpatialDomain']['Geometry']['CoordinateSystem']) + ', '
        # ================
        result += self.checkBoundingRectangle(metadata['Spatial']['HorizontalSpatialDomain']['Geometry']['BoundingRectangle']) + ', , , , , , , , '
        # ================
        
        checkSpatialGranuleRepresent(metadata, script_results)

        # try:
        #     result += self.checkSpatialGranuleRepresent(metadata['Spatial']['GranuleSpatialRepresentation']) + ', , , , , , , , , , , '
        # except KeyError:
        #     result += "np - Please provide a granule spatial representation for this dataset. This is a required field." + ', , , , , , , , , , , '
        # ================

        checkSpatInfoHorGeoDatumName(metadata, script_results)

        # try:
        #     result += self.checkSpatInfoHorGeoDatumName(metadata['SpatialInfo']['HorizontalCoordinateSystem']['GeodeticModel']['HorizontalDatumName']) + ', '
        # except KeyError:
        #     result += "np"

        return result

    end

    def checkShortName(metadata, script_results)
        val = metadata['ShortName']
        p "Input of checkShortName() is " + val
        if val.nil?
          script_results['ShortName'] = "np - Please provide a short name for this dataset." 
          return 
        else
          script_results['ShortName'] = "OK"
          return 
        end
    end

    def checkVersionID(metadata, script_results)
        val = metadata['VersionId']
        p "Input of checkVersionID() is " + val
        if val.nil?
          script_results['VersionID'] = "np - Please provide a version id for this dataset."
          return 
        else
          script_results['VersionID'] = "OK"
          return
        end
    end

    def time_check(time_string, field_name)
      if time_string.nil?
          return "np - Please provide an " + field_name + " for this dataset. This is a required field."
      end

      if !(val[-1] == "Z")
          return field_name + " error"
      end

      val = val.chomp("Z")
      t_record = DateTime.parse(val)
      # t_record = datetime.strptime(val, '%Y-%m-%dT%H:%M:%S.%f')
      if t_record.second_fraction.to_f > 999
          return field_name + " error"
      end

      t_now = DateTime.now()
      if t_record > t_now
          return field_name + " error"
      end
      
      return "OK"   
    end

    def setFromJSONUrl(theURL)
        newSet = []
        response = HTTParty.get(theURL)
        keywords = JSON.parse(response.body)["concepts"]
        keywords.each do |keywordEntry|
            newSet.push(keywordEntry["prefLabel"])
        end
        newSet
    end


    def checkInsertTime(metadata, script_results)
      if metadata['InsertTime'].nil?
        script_results['InsertTime'] = "np - Please provide an insert time for this dataset. This is a required field."
        return
      else 
        val = metadata['InsertTime']
        p "Input of checkInsertTime() is " + val
        script_results['InsertTime'] = time_check(val, "Insert Time")    
        return
      end 
    end     

    def checkLastUpdate(metadata, script_results)
        if metadata['LastUpdate'].nil?
            script_results["LastUpdate"] = "np - Please provide an last update time for this dataset. This is a required field."
        end
        val = metadata['LastUpdate']
        script_results["LastUpdate"] = time_check(val)
        return


        # print "Input of checkLastUpdate() is " + val
        # try:
        #     if val == None:
        #         return "np - Please provide an last update time for this dataset. This is a required field."
        #     elif not val.endswith("Z"):
        #         return "Update time error"
        #     val = val.replace("Z", "")
        #     t_record = datetime.strptime(val, '%Y-%m-%dT%H:%M:%S.%f')
        #     if t_record.microsecond > 999:
        #         return "Update time error"
        #     t_now = datetime.now()
        #     if t_record > t_now:
        #         return "Update time error"
        #     return "OK"
        # except ValueError:
            # return "Update time error"

    end

    def checkLongName(metadata, script_results)
        if metadata['LongName'].nil?
            script_results["LongName"] = "np"
            return
        end

        val = metadata['LongName']
        platformData = HTTParty.get(PlatformURL)
        platformList = CSV.parse(platformData.body)
        x.shift(2)

        platformKeys = []
        platformList.each do |entry|
            platformList.push(entry[3])
        end

        if val == ""
            script_results["LongName"] = "np"
        elsif !platformList.include? val
            script_results["LongName"] = "Platform Long Name does not conform to GCMD Version 8.4"
        else
            script_results["LongName"] = "OK"
        end

        return


        # print "Input of checkLongName() is " + val
        # PlatformKeys = list()
        # response = urllib2.urlopen(PlatformURL)
        # data = csv.reader(response)
        # next(data)  # Skip the first two line information
        # next(data)
        # for item in data:
        #     PlatformKeys += item[3:4]
        # PlatformKeys = list(set(PlatformKeys))
        # response.close()

        # if val == None:
        #     return "np"
        # if val not in PlatformKeys:
        #     return "Platform Long Name does not conform to GCMD Version 8.4"
        # else:
        #     return "OK"
    end
        



    def checkCollectionState(metadata, script_results)
        if metadata['CollectionState'].nil?
            script_results["CollectionState"] = "np"
        end
        states = ['PLANNED', 'IN WORK', 'COMPLETE']
        val = metadata['CollectionState']
        if val == ""
            script_results["CollectionState"] = "np"
        elsif !states.include? val
            script_results["CollectionState"] = "Invalid Response"
        else
            script_results["CollectionState"] = "OK"
        end
        return

        # print "Input of checkCollectionState() is " + val
        # states = ('PLANNED', 'IN WORK', 'COMPLETE')
        # if val == None:
        #     return "np"
        # elif val not in states:
        #     return "Invalid response"
        # else:
        #     return "OK"

    end

    def checkDataSetID(metadata, script_results)
        if metadata['DataSetId'].nil?
            script_results["DataSetId"] = "np"
            return
        end

        val = metadata['DataSetId']
        if val == ""
            script_results["DataSetId"] = "np - Please provide data set Id for this dataset. This is a required field."
            return
        else
            script_results["DataSetId"] = "OK"
            return
        end
        # print "Input of checkDateSetID() is " + val
        # if val == None:
        #     return "np - Please provide data set Id for this dataset. This is a required field."
        # else:
        #     return "OK"

    end

    def checkDesc(metadata, script_results):
        if metadata['Description'].nil?
          script_results['Description'] = "np - Please provide an abstract for this dataset."
          return
        else 
          val = metadata['Description']
          p "Input of checkDesc() is " + val[0:20]
          if val.nil?
              script_results['Description'] = "np - Please provide an abstract for this dataset."
              return 
          end
          if val.length < 50
              script_results['Description'] = "Dataset description may be inadequate."
              return 
          end              
          
          script_results['Description'] = "OK"
          return
        end
    end    

    def checkProcLevelID(metadata, script_results)
        if metadata['ProcessingLevelId'].nil?
          script_results['ProcessingLevelId'] = "np - Please provide a processing level Id for this dataset. This is a required field."
          return
        else
          val = metadata['ProcessingLevelId']
          p "Input of checkProcLevelID() is " + val
          levels = ['0', '1A', '1B', '2', '3', '4']
          if val.nil?
              metadata['ProcessingLevelId'] = "Please provide a processing level Id for this dataset. This is a required field."
              return
          elsif val == '1'
              metadata['ProcessingLevelId'] = "\"\'1\' is not a valid Processing Level ID; please choose either \'1A\' or \'1B\'.\""
              return
          elsif !levels.include? val
              metadata['ProcessingLevelId'] = "Double check processing level Id."
              return
          else
              metadata['ProcessingLevelId'] = "OK"
              return
          end
        end
    end

    def checkArchiveCenter(metadata, script_results)
        if metadata['ArchiveCenter'].nil?
            script_results["ArchiveCenter"] = "np - Please provide an archive center for this dataset."
            return
        else
            archCents = ['ASDC', 'GESDISC', 'LARC', 'SEDAC', 'GHRC', 'NSIDC', 'LPDAAC', 'ORNL_DAAC', 'OB.DAAC', 'Alaska Satellite Facility', 'PO.DAAC', 'CDDIS', 'LAADS']
            val = metadata["ArchiveCenter"]
            if val == ""
                script_results["ArchiveCenter"] = "np - Please provide an archive center for this dataset."
                return
            elsif val == 'GHRC'
                script_results["ArchiveCenter"] = "Currently listed as \"GHRC.\" This field needs to follow vocabulary from the GCMD \"Data Centers\" keyword list: http://gcmdservices.gsfc.nasa.gov/static/kms/providers/providers.csv. According to GCMD the archive center should be listed as \"NASA/MSFC/GHRC.\" GCMD should be contacted for a change request if GHRC does not agree with this nomenclature."
                return
            elsif !archCents.include? val
                script_results["ArchiveCenter"] = "Check archive center."
                return
            else
                if metadata['ProcessingCenter'].nil?
                    script_results["ArchiveCenter"] = "OK"
                    return
                else
                    if metadata['ProcessingCenter'] != val
                        script_results["ArchiveCenter"] = "Consistency Error"
                        return
                    end
                end
            end
        end
        # print "Input of checkArchiveCenter() is " + val
        # ArchCents = ('ASDC', 'GESDISC', 'LARC', 'SEDAC', 'GHRC', 'NSIDC', 'LPDAAC', 'ORNL_DAAC', 'OB.DAAC', 'Alaska Satellite Facility', 'PO.DAAC', 'CDDIS', 'LAADS')
        # if val == None:
        #     return "np - Please provide an archive center for this dataset."
        # elif val == 'GHRC':
        #     return "Currently listed as \"GHRC.\" This field needs to follow vocabulary from the GCMD \"Data Centers\" keyword list: http://gcmdservices.gsfc.nasa.gov/static/kms/providers/providers.csv. According to GCMD the archive center should be listed as \"NASA/MSFC/GHRC.\" GCMD should be contacted for a change request if GHRC does not agree with this nomenclature."
        # elif val not in ArchCents:
        #     return "Check archive center."
        # else:
        #     if procCenter != None and procCenter != val:
        #         return "Consistency error"
        # return "OK"
    end

    def checkDateFormat(metadata, script_results)
        if metadata['DataFormat'].nil?
            script_results['DateFormat'] = "np - Recommend providing data format."
            return
        end
        val = metadata['DateFormat']
        p "Input of checkDateFormat() is " + val
        if val == ""
            script_results['DateFormat'] = "np - Recommend providing data format."
            return
        else
            script_results['DateFormat'] = "OK"
            return
        end

    def checkSpatialKey(metadata, script_results)
        if metadata['SpatialKeywords'].nil? || metadata['SpatialKeywords']['Keyword'].nil?
            script_results["SpatialKey"] = "np"
        end

        val = metadata['SpatialKeywords']['Keyword']
        p "Input of checkSpatialKey() is " + val
        if val == ""
            script_results["SpatialKey"] = "np" 
            return 
        end
        spatialKeys = setFromJSONUrl(LocationKeywordURL)
        # response = urllib2.urlopen(LocationKeywordURL)
        # data = csv.reader(response)
        # next(data)  # Skip the first line information
        # for item in data:
            # SpatialKeys += item[0:5]    # Skip UUID column
        # SpatialKeys = list(set(SpatialKeys))
        # response.close()
        valArray = val.split(',')
        valArray.each do |location|
            if !spatialKeys.include? location
                script_results["SpatialKey"] = "The spatial keyword is not listed in GCMD or contains an error."
                return
            end
        end

        script_results["SpatialKey"] = "OK"
        return

        # if ', ' in val:
        #     for location in val.split(', '):
        #         if location not in SpatialKeys:
        #             return "The spatial keyword is not listed in GCMD or contains an error."
        # else:
        #     if val not in SpatialKeys:
        #         return "The spatial keyword is not listed in GCMD or contains an error."
        # return "OK"

    end

    def checkTemporalKeyword(metadata, script_results)
        if metadata['TemporalKeywords'].nil?  || metadata['TemporalKeywords']['Keyword'].nil?
            val = metadata['TemporalKeywords']
            val.each do |keyword|
                if keyword['Keyword'] == ""
                    script_results["TemporalKeyword"] = "np"
                    return
                end
            end
            script_results["TemporalKeyword"] = "quality check"
            return
        end

        val = metadata['TemporalKeywords']['Keyword']
        p "Input of checkTemporalKeyword() is ..."
        if val == ""
            script_results["TemporalKeyword"] = "np"
        else
            script_results["TemporalKeyword"] = "quality check"
        end
        return

        
        # if length == 1:
        #     if len(val) != 0:
        #         return "quality check"
        # else:
        #     for i in range(0, length):
        #         if len(val[i][Keyword]) != 0:
        #             return "quality check"
        # return "np"
    end

    def checkBeginDateTime(metadata, script_results)
        if metadata['Temporal'].nil? || metadata['Temporal']['RangeDateTime'].nil? || metadata['Temporal']['RangeDateTime']['BeginningDateTime'].nil?
            script_results["BeginningDateTime"] = "Check for single date time or periodic date time fields"
            return
        end
        val = metadata['Temporal']['RangeDateTime']['BeginningDateTime']    
        p "Input of checkBeginDateTime() is " + val
        script_results["BeginningDateTime"] = time_check(val, "beginning date time")
        return
    end

    def checkEndDateTime(metadata, script_results)
        if metadata['Temporal'].nil? || metadata['Temporal']['RangeDateTime'].nil? || metadata['Temporal']['RangeDateTime']['EndingDateTime'].nil?
            script_results["EndDateTime"] = "Check for single date time or periodic date time fields"
            return
        end
        val = metadata['Temporal']['RangeDateTime']['EndingDateTime']
        p "Input of checkEndDateTime() is " + val
        script_results["EndDateTime"] = time_check(val, "end date time")
        return
    end

    def checkContactEmail(metadata, script_results)
        if metadata['Contacts']['Contact']['OrganizationEmails']['Email'].nil?
            if metadata['Contacts']['Contact']['OrganizationEmails'].nil?
                script_results["ContactEmail"] = "np"
                return
            end
            val = metadata['Contacts']['Contact']['OrganizationEmails']
            val.each do |contact|
                if contact['Email'] == 'ghrc-dmg@itsc.uah.edu'
                    script_results["ContactEmail"] = 'Please change from "ghrc-dmg@itsc.uah.edu" to "support-ghrc@earthdata.nasa.gov" since this is currently listed as the contact email on the GHRC website: https://ghrc.nsstc.nasa.gov/home/contact-us'
                    return
                end
            end
            script_results["ContactEmail"] = "OK"
            return
        end
        p "Input of checkContactEmail() is ..." 
        val = metadata['Contacts']['Contact']['OrganizationEmails']['Email']
        if val == 'ghrc-dmg@itsc.uah.edu'
            script_results["ContactEmail"] = 'Please change from "ghrc-dmg@itsc.uah.edu" to "support-ghrc@earthdata.nasa.gov" since this is currently listed as the contact email on the GHRC website: https://ghrc.nsstc.nasa.gov/home/contact-us'
            return
        else
            script_results["ContactEmail"] = "OK"
            return    
        end
    end

    def checkContactRole(self, val)
        if metadata['Contacts']['Contact']['Role'].nil?
            script_results["ContactRole"] = "Contact Role Blank"
            end
        end
        val = metadata['Contacts']['Contact']['Role']
        p "Input of checkContactRole() is " + val
        if val == ""
            script_results["ContactRole"] = "np - Please provide a role for the contact person/organization for this dataset."
        else
            script_results["ContactRole"] = "OK"
            return
        end
    end


    def checkSciKey(metadata, script_results, scriptName, keyName, JSONurl)
        keyList = setFromJSONUrl(JSONurl)
        if metadata['ScienceKeywords'].nil? || metadata['ScienceKeywords']['ScienceKeyword'].nil? || metadata['ScienceKeywords']['ScienceKeyword'][keyName].nil?
            if metadata['ScienceKeywords'].nil? || metadata['ScienceKeywords']['ScienceKeyword'].nil?
                script_results[scriptName] = "np - Please provide at least one science category keyword for this dataset. This is a required field."
                return
            else
                sciList = metadata['ScienceKeywords']['ScienceKeyword']
                sciList.each do |sciEntry|
                    val = sciEntry[keyName]
                    if val == ""
                        script_results[scriptName] = "np - Please provide at least one science #{keyName} for this dataset. This is a required field."
                        return
                    elsif !keyList.include? val
                        script_results[scriptName] = "Keyword does not conform to GCMD Version 8.4"
                        return 
                    end
                end
                script_results[scriptName] = "OK- quality check"
                return
            end
        end
        val = metadata['ScienceKeywords']['ScienceKeyword'][keyName]

        if val == ""
            script_results[scriptName] = "np - Please provide at least one science #{keyName} for this dataset. This is a required field."
        elsif !keyList.include? val
            script_results[scriptName] = "Keyword does not conform to GCMD Version 8.4"
        else   
            script_results[scriptName] = "OK- quality check"
        end
        return
    end

    def checkSciKeyCategory(metadata, script_results)
        checkSciKey(metadata, script_results, 'SciKeyCategory', 'CategoryKeyword', ScienceKeywordURL)

        # print "Input of checkSciKeyCategory() is ..."
        # SciCategoryKeys = list()
        # response = urllib2.urlopen(ScienceKeywordURL)
        # data = csv.reader(response)
        # next(data)  # Skip the first two line information
        # next(data)
        # for item in data:
        #     SciCategoryKeys += item[0:1]
        # SciCategoryKeys = list(set(SciCategoryKeys))
        # response.close()
        # if length == 1:
        #     if val == None:
        #         return "np - Please provide at least one science category keyword for this dataset. This is a required field."
        #     if val not in SciCategoryKeys:
        #         return "Keyword does not conform to GCMD Version 8.4"
        # else:
        #     for i in range(0, length):
        #         if val[i]['CategoryKeyword'] == None:
        #             return "np - Please provide at least one science category keyword for this dataset. This is a required field."
        #         if val[i]['CategoryKeyword'] not in SciCategoryKeys:
        #             return "Keyword does not conform to GCMD Version 8.4"
        # return "OK- quality check"
    end

    def checkSciKeyTopic(metadata, script_results)
        checkSciKey(metadata, script_results, 'SciKeyTopic', 'TopicKeyword', ScienceKeywordURL)
        # print "Input of checkSciKeyTopic() is ..."
        # SciTopicKeys = list()
        # response = urllib2.urlopen(ScienceKeywordURL)
        # data = csv.reader(response)
        # next(data)  # Skip the first two line information
        # next(data)
        # for item in data:
        #     SciTopicKeys += item[1:2]
        # SciTopicKeys = list(set(SciTopicKeys))
        # response.close()
        # if length == 1:
        #     if val == None:
        #         return "np - Please provide at least one science topic keyword for this dataset. This is a required field."
        #     if val not in SciTopicKeys:
        #         return "Keyword does not conform to GCMD Version 8.4"
        # else:
        #     for i in range(0, length):
        #         if val[i]['TopicKeyword'] == None:
        #             return "np - Please provide at least one science topic keyword for this dataset. This is a required field."
        #         if val[i]['TopicKeyword'] not in SciTopicKeys:
        #             return "Keyword does not conform to GCMD Version 8.4"
        # return "OK- quality check"
    end

    def checkSciKeyTerm(metadata, script_results)
        checkSciKey(metadata, script_results, 'SciKeyTerm', 'TermKeyword', ScienceKeywordURL)
        # print "Input of checkSciKeyTerm() is ..."
        # SciTermKeys = list()
        # response = urllib2.urlopen(ScienceKeywordURL)
        # data = csv.reader(response)
        # next(data)  # Skip the first two line information
        # next(data)
        # for item in data:
        #     SciTermKeys += item[2:3]
        # SciTermKeys = list(set(SciTermKeys))
        # response.close()
        # if length == 1:
        #     if val == None:
        #         return "np - Please provide at least one science term keyword for this dataset. This is a required field."
        #     if val not in SciTermKeys:
        #         return "The science term keyword does not conform to GCMD Version 8.4"
        # else:
        #     for i in range(0, length):
        #         if val[i]['TermKeyword'] == None:
        #             return "np - Please provide at least one science term keyword for this dataset. This is a required field."
        #         if val[i]['TermKeyword'] not in SciTermKeys:
        #             return "The science term keyword does not conform to GCMD Version 8.4"
        # return "OK- quality check"
    end

    def checkSciKeyVarL1(self, val, length):
        # print "Input of checkSciKeyVarL1() is ..."
        
        # SciVarL1Keys = list()
        # response = urllib2.urlopen(ScienceKeywordURL)
        # data = csv.reader(response)
        # next(data)  # Skip the first two line information
        # next(data)
        # for item in data:
        #     SciVarL1Keys += item[3:4]
        # SciVarL1Keys = list(set(SciVarL1Keys))
        # response.close()
        # if length == 1:
        #     if val == None:
        #         return "np"
        #     if val not in SciVarL1Keys:
        #         return "The variable level 1 keyword does not conform to GCMD Version 8.4"
        # else:
        #     for i in range(0, length):
        #         if val[i]['VariableLevel1Keyword']['Value'] == None:
        #             return "np"
        #         if val[i]['VariableLevel1Keyword']['Value'] not in SciVarL1Keys:
        #             return "The variable level 1 keyword does not conform to GCMD Version 8.4"
        # return "OK- quality check"


        keyList = setFromJSONUrl(ScienceKeywordURL)

        if metadata['ScienceKeywords'].nil? || metadata['ScienceKeywords']['ScienceKeyword'].nil? || metadata['ScienceKeywords']['ScienceKeyword']['VariableLevel1Keyword'].nil? || metadata['ScienceKeywords']['ScienceKeyword']['VariableLevel1Keyword']['Value'].nil?
            if metadata['ScienceKeywords'].nil? || metadata['ScienceKeywords']['ScienceKeyword'].nil?
                script_results['SciKeyVarL1'] = "np - Please provide at least one science category keyword for this dataset. This is a required field."
                return
            else
                sciList = metadata['ScienceKeywords']['ScienceKeyword']
                sciList.each do |sciEntry|
                    val = sciEntry['VariableLevel1Keyword']['Value']                    
                    if val == ""
                        script_results['SciKeyVarL1'] = "np"
                        return
                    elsif !keyList.include? val
                        script_results[scriptName] = "The variable level 1 keyword does not conform to GCMD Version 8.4"
                        return 
                    end
                end
                script_results[scriptName] = "OK- quality check"
                return
            end
        end
        val = metadata['ScienceKeywords']['ScienceKeyword']['VariableLevel1Keyword']['Value']
        
        if val == ""
            script_results[scriptName] = "np"
        elsif !keyList.include? val
            script_results[scriptName] = "The variable level 1 keyword does not conform to GCMD Version 8.4"
        else   
            script_results[scriptName] = "OK- quality check"
        end
        return

    end

    def checkPlatformShortName(metadata, script_results)
        # print "Input of checkPlatformShortName() is ..."
        # PlatformKeys = list()
        # response = urllib2.urlopen(PlatformURL)
        # data = csv.reader(response)
        # next(data)  # Skip the first two line information
        # next(data)
        # for item in data:
        #     PlatformKeys += item[2:3]
        # PlatformKeys = list(set(PlatformKeys))
        # response.close()
        # if length == 1:
        #     if val == None:
        #         return "np - Please provide at least one platform for this dataset. This is a required field."
        #     if val not in PlatformKeys:
        #         return "The platform short name does not conform to GCMD Version 8.4"
        # else:
        #     for i in range(0, length):
        #         if val[i]['ShortName'] == None:
        #             return "np - Please provide at least one platform for this dataset. This is a required field."
        #         if val[i]['ShortName'] not in PlatformKeys:
        #             return "The platform short name does not conform to GCMD Version 8.4"
        # return "OK- quality check"


        platformKeys = setFromJSONUrl(PlatformURL)
        if metadata['Platforms'].nil? || metadata['Platforms']['Platform'].nil? || metadata['Platforms']['Platform']['ShortName'].nil?
            if metadata['Platforms'].nil? || metadata['Platforms']['Platform'].nil?
                script_results["PlatformShortName"] = "np"
                return
            else
                names = metadata['Platforms']['Platform']
                names.each do |entry|
                    val = entry["ShortName"]
                    if val == ""
                        script_results["PlatformShortName"] = "np"
                        return
                    elsif !platformKeys.include? val
                        script_results["PlatformShortName"] = "Platform Long Name does not conform to GCMD Version 8.4"
                        return
                    end
                end
                script_results["PlatformShortName"] = "OK"
                return
            end
        end
        val = metadata['Platforms']['Platform']['ShortName']
        if val == ""
            script_results["PlatformShortName"] = "np"
        elsif !platformKeys.include? val
            script_results["PlatformShortName"] = "Platform Long Name does not conform to GCMD Version 8.4"
        else
            script_results["PlatformShortName"] = "OK"
        return
    end

    def checkPlatformType(self, val, length):
        print "Input of checkPlatformType() is ..."
        PlatformTypeKeys = list()
        response = urllib2.urlopen(PlatformURL)
        data = csv.reader(response)
        next(data)  # Skip the first two line information
        next(data)
        for item in data:
            PlatformTypeKeys += item[0:1]
        PlatformTypeKeys = list(set(PlatformTypeKeys))
        response.close()

        if length == 1:
            if val == 'SATELLITE':
                return "Change to \'Earth Observation Satellites\' to Conform with GCMD Version 8.4 keywords."
            elif val == 'IN SITU LAND BASED':
                return "Change to \'In Situ Land-based Platforms\' to conform with GCMD Version 8.4 keywords."
            elif val == 'AIRCRAFT':
                return "Please change from \"AIRCRAFT\" to \"Aircraft\" to precisely match GCMD keywords. This will allow case sensitive programming languages to identify \"Aircraft\" as a GCMD keyword."
            elif val not in PlatformTypeKeys:
                return "Platform Type does not conform to GCMD Version 8.4"
            else:
                return "OK"
        else:
            for i in range(0, length):
                if val == 'SATELLITE':
                    return "Change to \'Earth Observation Satellites\' to Conform with GCMD Version 8.4 keywords."
                elif val == 'IN SITU LAND BASED':
                    return "Change to \'In Situ Land-based Platforms\' to conform with GCMD Version 8.4 keywords."
                elif val == 'AIRCRAFT':
                    return "Change to \'In Situ Land-based Platforms\' to conform with GCMD Version 8.4 keywords."
                elif val not in PlatformTypeKeys:
                    return "Platform Type does not conform to GCMD Version 8.4"
                else:
                    return "OK"

    def checkInstrShortName(self, val, platformNum):
        print "Input of checkInstrShortName() is ..."
        processInstrCount = 0
        InstrumentKeys = list()
        response = urllib2.urlopen(InstrumentURL)
        data = csv.reader(response)
        next(data)  # Skip the first two line information
        next(data)
        for item in data:
            InstrumentKeys += item[4:5]
        InstrumentKeys = list(set(InstrumentKeys))
        response.close()

        if platformNum == 1:
            try:
                if val['Instruments']['Instrument']['ShortName'] == None:
                    return "np - Please provide at least one instrument relevant to the platform provided for this dataset. This is a required field."
                if not any(s.lower() == val['Instruments']['Instrument']['ShortName'].lower() for s in InstrumentKeys):
                    return "The instrument short name does not conform to GCMD Version 8.4"
                processInstrCount += 1
            except TypeError:
                instrNum = len(val['Instruments']['Instrument'])
                for instr in range(0, instrNum):
                    if val['Instruments']['Instrument'][instr]['ShortName'] == None:
                        return "np - Please provide at least one instrument relevant to the platform provided for this dataset. This is a required field."
                    if not any(s.lower() == val['Instruments']['Instrument'][instr]['ShortName'].lower() for s in InstrumentKeys):
                        return "The instrument short name does not conform to GCMD Version 8.4"
                    processInstrCount += 1
            except KeyError:
                print "Access Key Error!"
        else:
            for i in range(0, platformNum):
                try:
                    if val[i]['Instruments']['Instrument']['ShortName'] == None:
                        return "np - Please provide at least one instrument relevant to the platform provided for this dataset. This is a required field."
                    if not any(s.lower() == val[i]['Instruments']['Instrument']['ShortName'].lower() for s in InstrumentKeys):
                        return "The instrument short name does not conform to GCMD Version 8.4"
                    processInstrCount += 1
                except TypeError:
                    instrNum = len(val[i]['Instruments']['Instrument'])
                    for instr in range(0, instrNum):
                        if val[i]['Instruments']['Instrument'][instr]['ShortName'] == None:
                            return "np - Please provide at least one instrument relevant to the platform provided for this dataset. This is a required field."
                        if not any(s.lower() == val[i]['Instruments']['Instrument'][instr]['ShortName'].lower() for s in InstrumentKeys):
                            return "The instrument short name does not conform to GCMD Version 8.4"
                        processInstrCount += 1
                except KeyError:
                    continue
        if processInstrCount != 0:
            return "OK- quality check"
        else:
            return "np - Please provide at least one instrument relevant to the platform provided for this dataset. This is a required field."

    def checkCampaignShortName(self, val, length):
        print "Input of checkCampaignShortName() is ..."
        CampaignKeys = list()
        response = urllib2.urlopen(ProjectURL)
        data = csv.reader(response)
        next(data)  # Skip the first two line information
        next(data)
        for item in data:
            CampaignKeys += item[1:2]
        CampaignKeys = list(set(CampaignKeys))
        response.close()
        if length == 1:
            if val == None:
                return "np - Please provide a campaign name for this dataset. This is a required field."
            if val not in CampaignKeys:
                return "The campaign short name does not conform to GCMD Version 8.4"
        else:
            for i in range(0, length):
                if val[i]['ShortName'] == None:
                    return "np - Please provide a campaign name for this dataset. This is a required field."
                if val[i]['ShortName'] not in CampaignKeys:
                    return "The campaign short name does not conform to GCMD Version 8.4"
        return "OK- quality check" 

    def checkOnlineAccessURL(self, val, length, ArchCenter):
        print "Input of checkOnlineAccessURL() is ..."
        brokenURLcount = 0
        msg = ""
        try:
            url = ArchtoURLs[ArchCenter]
        except KeyError:
            url = ''
        if length == 1:
            if val == None:
                return "np - field present but empty."
            if not val.startswith(url):
                return "Online Access URL does not lead to a URS direct download page."
            try:
                connection = urllib2.urlopen(val)
                if connection:
                    connection.close()
            except (urllib2.HTTPError, urllib2.URLError) as e:
                return "Broken link: " + val
        else:
            for i in range(0, length):
                if val[i]['URL'] == None:
                    return "np - field present but empty."
                if not val[i]['URL'].startswith(url):
                    return "Online Access URL does not lead to a URS direct download page."
                try:
                    connection = urllib2.urlopen(val[i]['URL'])
                    if connection:
                        connection.close()
                except (urllib2.HTTPError, urllib2.URLError, socket.timeout) as e:
                    msg += "Broken link: " + val[i]['URL'] + ";"
                    brokenURLcount += 1
                    # return "Broken link: " + val[i]['URL']
        if brokenURLcount != 0:
            return msg
        else:
            return "OK- quality check" 

    def checkOnlineURLDesc(self, val, length):
        print "Input of checkOnlineURLDesc() is ..."
        msg = ''
        if length == 1:
            if val == None:
                return "Recommend adding a brief URL Description."
            else:
                return "OK"
        else:
            for i in range(0, length):
                try:
                    if val[i]['Description'] == None:
                        return "Recommend adding a brief URL Description."
                except KeyError:      
                    return "Recommend adding a brief URL Description."  
        return "OK"

    def checkSpatialHorGeoCoor(self, val):
        print "Input of checkSpatialHorGeoCoor() is " + val
        if val == None:
            return "np - Please provide a horizontal coordinate system for this dataset. This is a required field."
        else:
            return "OK"

    def checkBoundingRectangle(self, val):
        print "Input of checkBoundingRectangle() is ..."
        msg = ''
        if float(val['WestBoundingCoordinate']) >= -180 and float(val['WestBoundingCoordinate']) <= 180:
            msg += "OK - quality check, "
        else:
            msg += "Coordinate points may not be valid, "
        if float(val['NorthBoundingCoordinate']) >= -180 and float(val['WestBoundingCoordinate']) <= 180:
            msg += "OK - quality check, "
        else:
            msg += "Coordinate points may not be valid, "
        if float(val['EastBoundingCoordinate']) >= -180 and float(val['EastBoundingCoordinate']) <= 180:
            msg += "OK - quality check, "
        else:
            msg += "Coordinate points may not be valid, "
        if float(val['SouthBoundingCoordinate']) >= -180 and float(val['SouthBoundingCoordinate']) <= 180:
            msg += "OK - quality check, "
        else:
            msg += "Coordinate points may not be valid, "
        return msg

    def checkOnlineResourceURL(self, val, length):
        print "Input of checkOnlineResourceURL() is ..."
        brokenURLcount = 0
        msg = ""
        if length == 1:
            if val == None:
                return "np- field present but empty"
            try:
                connection = urllib2.urlopen(val, timeout=5)
                if connection:
                    connection.close()
            except (urllib2.HTTPError, urllib2.URLError, socket.timeout) as e:
                return "Broken link: " + val
        else:        
            for i in range(0, length):
                try:
                    if val[i]['URL'] == None:
                        return "np- field present but empty"
                    connection = urllib2.urlopen(val[i]['URL'], timeout=5)
                    if connection:
                        connection.close()
                except (urllib2.HTTPError, urllib2.URLError, socket.timeout) as e:
                    msg += "Broken link: " + val[i]['URL'] + ";"
                    brokenURLcount += 1
                    # return "Broken link: " + val[i]['URL']
        if brokenURLcount != 0:
            return msg
        else:
            return "OK"

    def checkOnlineResourceURLDesc(self, val, length):
        print "Input of checkOnlineResourceURLDesc() is ..."
        msg = ''
        if length == 1:
            if val == None:
                return "Recommend adding brief descriptions for all Online Resource URLs."
            else:
                return "OK"
        else:
            for i in range(0, length):
                try:
                    if val[i]['Description'] == None:
                        return "Recommend adding brief descriptions for all Online Resource URLs"
                except KeyError:      
                    return "Recommend adding brief descriptions for all Online Resource URLs"
        return "OK"

    def checkOnlineResourceType(self, val, length):
        print "Input of checkOnlineResourceType() is ..."
        ResourcesTypes = list()
        response = urllib2.urlopen(ResourcesTypeURL)
        data = csv.reader(response)
        next(data)  # Skip the first two row information
        next(data)
        for item in data:
            ResourcesTypes += item[0:1]
        ResourcesTypes = list(set(ResourcesTypes))
        response.close()

        if length == 1:
            if val == None:
                return "np"
            elif val not in ResourcesTypes:
                return "URL Types are translated to GCMD vocabulary in CMR. In order to avoid translation errors: please choose an appropriate URL Content Type for all Online Resource URLs from the following keywords list: http://gcmdservices.gsfc.nasa.gov/static/kms/rucontenttype/rucontenttype.csv"
        else:
            for i in range(0, length):
                try:
                    if val[i]['URL'] != None:
                        try:
                            if val[i]['Type'] == None:
                                return "np"
                            elif val not in ResourcesTypes:
                                return "URL Types are translated to GCMD vocabulary in CMR. In order to avoid translation errors: please choose an appropriate URL Content Type for all Online Resource URLs from the following keywords list: http://gcmdservices.gsfc.nasa.gov/static/kms/rucontenttype/rucontenttype.csv"
                        except KeyError:
                            return "np"    
                except KeyError:
                    continue
        return "OK"

    def checkSpatialGranuleRepresent(metadata, script_results)
        if metadata['Spatial'].nil? || metadata['Spatial']['GranuleSpatialRepresentation'].nil?
          script_results['GranuleSpatialRepresentation'] = "np - Please provide a granule spatial representation for this dataset. This is a required field."
          return
        else
          val = metadata['Spatial']['GranuleSpatialRepresentation']
          p "Input of checkSpatialGranuleRepresent() is " + val
          if val.nil?
            script_results['GranuleSpatialRepresentation'] = "np - Please provide a granule spatial representation for this dataset. This is a required field."
            return
          else
            script_results['GranuleSpatialRepresentation'] = "OK"
            return
          end
        end    
    end

    def checkSpatInfoHorGeoDatumName(metadata, script_results)

      if metadata['SpatialInfo'].nil? || metadata['SpatialInfo']['HorizontalCoordinateSystem'].nil? ||
          metadata['SpatialInfo']['HorizontalCoordinateSystem']['GeodeticModel'].nil? || metadata['SpatialInfo']['HorizontalCoordinateSystem']['GeodeticModel']['HorizontalDatumName'].nil?
        script_results['SpatInfoHorGeoDatumName'] = "np"
        return
      else
        val = metadata['SpatialInfo']['HorizontalCoordinateSystem']['GeodeticModel']['HorizontalDatumName']
        p "Input of checkSpatInfoHorGeoDatumName() is " + val
        if val.nil?
          script_results['SpatInfoHorGeoDatumName'] = "np"
          return
        else
          script_results['SpatInfoHorGeoDatumName'] = "OK"
          return 
        end
      end    
    end


end
