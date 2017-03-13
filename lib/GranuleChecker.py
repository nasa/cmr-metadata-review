'''
Copyright 2016, United States Government, as represented by the Administrator of 
the National Aeronautics and Space Administration. All rights reserved.
The "pyCMR" platform is licensed under the Apache License, Version 2.0 (the "License"); 
you may not use this file except in compliance with the License. You may obtain a 
copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
 
Unless required by applicable law or agreed to in writing, software distributed under 
the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF 
ANY KIND, either express or implied. See the License for the specific language 
governing permissions and limitations under the License.
'''

import csv
import urllib2
import socket
from collections import defaultdict
from datetime import *

PlatformURL = "http://gcmdservices.gsfc.nasa.gov/static/kms/platforms/platforms.csv"
InstrumentURL = "http://gcmdservices.gsfc.nasa.gov/static/kms/instruments/instruments.csv"
ProjectURL = "http://gcmdservices.gsfc.nasa.gov/static/kms/projects/projects.csv"
ResourcesTypeURL = "http://gcmdservices.gsfc.nasa.gov/static/kms/rucontenttype/rucontenttype.csv"


def fetchAllInstrs():
    print "Fetch all Instruments ..."
    InstrKeyWords = [[],[],[],[],[],[]]
    # Category, SciTopicKeys, SciTermKeys, SciVarL1Keys, SciVarL2Keys, SciVarL3Keys, SciDetailVar
    response = urllib2.urlopen(InstrumentURL)
    data = csv.reader(response)
    next(data)  # Skip the first two line information
    next(data)
    for item in data:
        InstrKeyWords[0] += item[0:1]
        InstrKeyWords[1] += item[1:2]
        InstrKeyWords[2] += item[2:3]
        InstrKeyWords[3] += item[3:4]
        InstrKeyWords[4] += item[4:5]
        InstrKeyWords[5] += item[5:6]
    for i in range(6):
        InstrKeyWords[i] = list(set(InstrKeyWords[i]))
    response.close()
    return InstrKeyWords    

class Checker():
    def checkAll(self, metadata):
        # result = ", "
        result = ""
        resultFields = ""
        
        # result += self.checkGranuleUR(metadata['GranuleUR']) + ', '
        # ================

        resultFields += 'InsertTime' + ', '
        try:
            result += self.checkInsertTime(metadata['InsertTime']) + ', '
        except KeyError:
            result += "np" + ', '
        # ================

        resultFields += 'LastUpdate' + ', '
        try:
            result += self.checkLastUpdate(metadata['LastUpdate'], metadata['DataGranule']['ProductionDateTime']) + ', '
        except KeyError:
            result += "np" + ', '
        # ================

        resultFields += 'DeleteTime' + ', '
        try:
            result += self.checkDeleteTime(metadata['DeleteTime'], metadata['DataGranule']['ProductionDateTime']) + ', , , '
        except KeyError:
            result += "np" + ', , , '
        # ================
        # try:
        #     result += self.checkShortNameAndVersionID(metadata['Collection']['ShortName'], metadata['Collection']['VersionId']) + ', '
        # except KeyError:
        #     result += "np, np" + ', '
        # ================

        resultFields += 'Collection/DataSetId' + ',,, '
        try:
            result += self.checkDataSetId(metadata['Collection']['DataSetId']) + ', , , '
        except KeyError:
            result += "np" + ', , , '
        # ================

        resultFields += 'DataGranule/SizeMBDataGranule' + ', ,,,,'
        try:
            result += self.checkSizeMBDataGranule(metadata['DataGranule']['SizeMBDataGranule']) + ', , , , , '
        except KeyError:
            result += "Granule file size not provided. Recommend providing a value for this field in the metadata" + ', , , , , '
        # ================
        # try:
        #     result += self.checkDayNightFlag(metadata['DataGranule']['DayNightFlag']) + ', '
        # except KeyError:
        #     result += "np" + ', '
        # ================


        resultFields += 'DataGranule/ProductionDateTime' + ', , , , '
        try:
            result += self.checkProductionDateTime(metadata['DataGranule']['ProductionDateTime'], metadata['InsertTime']) + ', , , , '
        except KeyError:
            result += "np" + ', , , , '
        # ================

        resultFields += 'Temporal/RangeDateTime/SingleDateTime' + ', '
        try:
            result += self.checkTemporalSingleTime(metadata['Temporal']['RangeDateTime']['SingleDateTime']) + ', '
        except KeyError:
            result += "np" + ', '
        # ================

        resultFields += 'Temporal/RangeDateTime/BeginningDateTime' + ', '
        try:
            result += self.checkTemporalBeginningTime(metadata['Temporal']['RangeDateTime']['BeginningDateTime']) + ', '
        except KeyError:
            result += "np" + ', '
        # ================


        resultFields += 'Temporal/RangeDateTime/EndingDateTime' + ', , , , , , , '
        try:
            result += self.checkTemporalEndingTime(metadata['Temporal']['RangeDateTime']['EndingDateTime']) + ', , , , , , , '
        except KeyError:
            result += "np" + ', , , , , , , '
        # ================


        resultFields += 'Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle' + ', , , , , , , , , , , , , , '
        try:
            result += self.checkBoundingRectangle(metadata['Spatial']['HorizontalSpatialDomain']['Geometry']['BoundingRectangle']) + ', , , , , , , , , , , , , , '
        except KeyError:
            result += "np, np, np, np" + ', , , , , , , , , , , , , , '
        # ================


        resultFields += 'OrbitCalculatedSpatialDomains/OrbitCalculatedSpatialDomain/EquatorCrossingDateTime' + ', , , , , , , , , , , , '
        try:
            result += self.checkEquatorCrossingTime(metadata['OrbitCalculatedSpatialDomains']['OrbitCalculatedSpatialDomain']['EquatorCrossingDateTime'], 1) + ', , , , , , , , , , , , '
        except TypeError:
            if metadata['OrbitCalculatedSpatialDomains'] != None and metadata['OrbitCalculatedSpatialDomains']['OrbitCalculatedSpatialDomain'] != None:
                length = len(metadata['OrbitCalculatedSpatialDomains']['OrbitCalculatedSpatialDomain'])
                result += self.checkEquatorCrossingTime(metadata['OrbitCalculatedSpatialDomains']['OrbitCalculatedSpatialDomain']['EquatorCrossingDateTime'], length) + ', , , , , , , , , , , ,'
            else:
                result += "np" + ', , , , , , , , , , , , '
        except KeyError:
            result += "np" + ', , , , , , , , , , , , '
        # ================  


        resultFields += 'Platforms/Platform/ShortName' + ', '
        try:
            result += self.checkPlatformShortName(metadata['Platforms']['Platform']['ShortName'], 1) + ', '
        except TypeError:
            if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                length = len(metadata['Platforms']['Platform'])
                result += self.checkPlatformShortName(metadata['Platforms']['Platform'], length) + ', '
            else:
                result += "np" + ', '
        except KeyError:
            result += "np" + ', '
        # ================
        # try:
        #     metadata['Platforms']['Platform']['ShortName']
        #     platform_num = 1
        #     result += self.checkInstrShortName(metadata['Platforms']['Platform'], platform_num) + ', , , '
        # except TypeError:
        #     if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
        #         platform_num = len(metadata['Platforms']['Platform'])
        #         result += self.checkInstrShortName(metadata['Platforms']['Platform'], platform_num) + ', , , '
        #     else:
        #         result += "np" + ', , , '
        # except KeyError:
        #     result += "np" + ', , , '
        # ================
        instruments = fetchAllInstrs()
        sensorShortResult = ''


        resultFields += 'Platforms/Platform' + ',,,'
        try:
            metadata['Platforms']['Platform']['ShortName']
            platform_num = 1
            ret, sensorShortResult = self.checkInstrShortName(metadata['Platforms']['Platform'], platform_num, instruments)
            result += ret + ', , , '
        except TypeError:
            if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                platform_num = len(metadata['Platforms']['Platform'])
                ret, sensorShortResult = self.checkInstrShortName(metadata['Platforms']['Platform'], platform_num, instruments)
                result += ret + ', , , '
            else:
                result += 'np' + ', , , '
        except KeyError:
            result += 'np' + ', , , '
        # ================  


        if len(sensorShortResult) == 0:
            result += 'np , , , , '
        else:
            result += sensorShortResult + ', , , , '
        # ================

        resultFields += 'Campaigns/Campaign/ShortName' + ', , , , , , , , , , '
        try:
            campaign_num = 1
            result += self.checkCampaignShortName(metadata['Campaigns']['Campaign']['ShortName'], campaign_num) + ', , , , , , , , , , '
        except TypeError:
            if metadata['Campaigns'] != None and metadata['Campaigns']['Campaign'] != None:
                campaign_num = len(metadata['Campaigns'])
                result += self.checkCampaignShortName(metadata['Campaigns'], campaign_num) + ', , , , , , , , , , '
        except KeyError:
            result += "np" + ', , , , , , , , , , '
        # ================



        resultFields += 'OnlineAccessURLs/OnlineAccessURL/URL' + ', '
        try:
            result += self.checkOnlineAccessURL(metadata['OnlineAccessURLs']['OnlineAccessURL']['URL'], 1) + ', '
        except TypeError:
            if metadata['OnlineAccessURLs'] != None:
                length = len(metadata['OnlineAccessURLs']['OnlineAccessURL'])
                result += self.checkOnlineAccessURL(metadata['OnlineAccessURLs']['OnlineAccessURL'], length) + ', '
            else:
                result += "No Online Access URL is provided" + ', '
        except KeyError:
            result += "No Online Access URL is provided" + ', '
        # ================


        resultFields += 'OnlineAccessURLs/OnlineAccessURL/URLDescription' + ', , '
        try:
            result += self.checkOnlineAccessURLDesc(metadata['OnlineAccessURLs']['OnlineAccessURL']['URLDescription'], 1) + ', , '
        except TypeError:
            if metadata['OnlineAccessURLs'] != None:
                length = len(metadata['OnlineAccessURLs']['OnlineAccessURL'])
                result += self.checkOnlineAccessURLDesc(metadata['OnlineAccessURLs']['OnlineAccessURL'], length) + ', , '
            else:
                result += "Recommend providing a brief URL description" + ', , '
        except KeyError:
            result += "Recommend providing a brief URL description" + ', , '
        # ================
        OnlineResourceURL_Cnt = 0



        resultFields += 'OnlineResources/OnlineResource/URL' + ', '
        try:
            result += self.checkOnlineResourceURL(metadata['OnlineResources']['OnlineResource']['URL'], 1) + ', '
            OnlineResourceURL_Cnt = 1
        except TypeError:
            if metadata['OnlineResources'] != None:
                length = len(metadata['OnlineResources']['OnlineResource'])
                OnlineResourceURL_Cnt = length
                result += self.checkOnlineResourceURL(metadata['OnlineResources']['OnlineResource'], length) + ', '
            else:
                result += "np" + ', '
        except KeyError:
            result += "np" + ', '
        # ================



        resultFields += 'OnlineResources/OnlineResource/Description' + ', '
        try:
            result += self.checkOnlineResourceDesc(metadata['OnlineResources']['OnlineResource']['Description'], 1) + ', '
        except TypeError:
            if metadata['OnlineResources'] != None:
                length = len(metadata['OnlineResources']['OnlineResource'])
                if length < OnlineResourceURL_Cnt:
                    result += "Recommend providing descriptions for all Online Resource URLs." + ', '
                else:
                    result += self.checkOnlineResourceDesc(metadata['OnlineResources']['OnlineResource'], length) + ', '
            else:
                result += "Recommend providing descriptions for all Online Resource URLs." + ', '
        except KeyError:
            result += "Recommend providing descriptions for all Online Resource URLs." + ', '
        # ================


        resultFields += 'OnlineResources/OnlineResource/Type' + ', , '
        try:
            result += self.checkOnlineResourceType(metadata['OnlineResources']['OnlineResource']['Type'], 1) + ', , '
        except TypeError:
            if metadata['OnlineResources'] != None:
                length = len(metadata['OnlineResources']['OnlineResource'])
                result += self.checkOnlineResourceType(metadata['OnlineResources']['OnlineResource'], length) + ', , '
            else:
                result += "np" + ', , '
        except KeyError:
            result += "np" + ', , '
        # ================

        resultFields += 'Orderable' + ', '
        try:
            result += self.checkOrderable(metadata["Orderable"]) + ', '
        except KeyError:
            result += "np" + ', '
        # ================

        resultFields += 'DataFormat' + ', '
        try:
            result += self.checkDataFormat(metadata["DataFormat"]) + ', '
        except KeyError:
            result += "Recommend providing the data format for the associated granule" + ', '
        # ================


        resultFields += 'Visible' + ', '
        try:
            result += self.checkVisible(metadata["Visible"]) + ', , , , , , , '
        except KeyError:
            result += "np" + ', , , , , , , '

        return result, resultFields



    def checkGranuleUR(self, val):
        print "Input of checkGranuleUR() is " + val
        if val == None:
            return "Provide a granule UR for this granule. This is a required field."
        else:
            return "OK"

    def checkInsertTime(self, val):
        print "Input of checkInsertTime() is " + val
        try:
            if val == None:
                return "np"
            if not val.endswith("Z"):
                return "1-Insert time error"
            val = val.replace("Z", "")
            t_record = datetime.strptime(val, '%Y-%m-%dT%H:%M:%S')
            if t_record.microsecond > 999:
                return "2-Insert time error"
            t_now = datetime.now()
            if t_record > t_now:
                return "3-Insert time error"
            return "OK - quality check"
        except ValueError:
            return "4-Insert time error"

    def checkLastUpdate(self, updateTime, prodTime):
        print "Input of checkLastUpdate() is " + updateTime + ', ' + prodTime
        try:
            if updateTime == None:
                return "np"
            elif not updateTime.endswith("Z"):
                return "Last update time error"
            updateTime = updateTime.replace("Z", "")
            t_record = datetime.strptime(updateTime, '%Y-%m-%dT%H:%M:%S')
            prodTime = prodTime.replace("Z", "")
            p_record = datetime.strptime(prodTime, '%Y-%m-%dT%H:%M:%S')
            if t_record.microsecond > 999:
                return "Last update time error"
            t_now = datetime.now()
            if t_record > t_now or t_record < p_record:
                return "Last update time error"
            return "OK - quality check"
        except ValueError:
            return "Last update time error"

    def checkDeleteTime(self, deleteTime, prodTime):
        print "Input of checkDeleteTime() is " + deleteTime + ', ' + prodTime
        try:
            if deleteTime == None:
                return "np"
            elif not deleteTime.endswith("Z"):
                return "Delete time error"
            deleteTime = deleteTime.replace("Z", "")
            t_record = datetime.strptime(deleteTime, '%Y-%m-%dT%H:%M:%S')
            prodTime = prodTime.replace("Z", "")
            p_record = datetime.strptime(prodTime, '%Y-%m-%dT%H:%M:%S')
            if t_record.microsecond > 999:
                return "Delete time error"
            t_now = datetime.now()
            if p_record > t_record:
                return "Delete time error"
            return "OK - quality check"
        except ValueError:
            return "Delete time error"        

    def checkShortNameAndVersionID(self, sname, vid):
        print "Input of checkShortNameAndVersionID() is " + sname + ', ' + vid
        if sname == None and vid == None:
            return "np, np"
        elif sname == None or vid == None:
            return "ShortName/VersionId Error; ShortName/VersionId Error"
        else:
            return "OK, OK"

    def checkDataSetId(set, val):
        print "Input of checkDataSetId() is " + val
        if val == None:
            return "np"
        elif val.isupper() or val.islower():
            return "Recommend that the Dataset Id use mixed case to optimize human readability."
        else:
            return "OK"

    def checkSizeMBDataGranule(set, val):
        print "Input of checkSizeMBDataGranule() is " + val
        if val == None:
            return "Granule file size not provided. Recommend providing a value for this field in the metadata."
        else:
            return "OK - quality check"

    def checkDayNightFlag(set, val):
        print "Input of checkDayNightFlag() is " + val
        DNFlags = ('DAY', 'NIGHT', 'BOTH', 'UNSPECIFIED')
        if val == None:
            return "np"
        elif val not in DNFlags:
            return "The day/night flag in the metadata is not an accepted value. Please choose a day/night flag from the following list: DAY / NIGHT / BOTH / UNSPECIFIED."
        else:
            return "OK"

    def checkProductionDateTime(self, prodTime, insertTime):
        print "Input of checkProductionDateTime() is " + prodTime + ', ' + insertTime
        try:
            if prodTime == None:
                return "np"
            if not prodTime.endswith("Z"):
                return "Production date time error"
            prodTime = prodTime.replace("Z", "")
            p_record = datetime.strptime(prodTime, '%Y-%m-%dT%H:%M:%S')
            insertTime = insertTime.replace("Z", "")
            i_record = datetime.strptime(insertTime, '%Y-%m-%dT%H:%M:%S')
            if p_record.microsecond > 999:
                return "Production date time error"
            t_now = datetime.now()
            if p_record > t_now:
                return "Production date time error"
            elif p_record != i_record:
                return "Format OK - does not match the Insert Time."
            return "OK - quality check"
        except ValueError:
            return "Production date time error"

    def checkTemporalSingleTime(self, val):
        print "Input of checkTemporalSingleTime() is " + val
        try:
            if val == None:
                return "np"
            if not val.endswith("Z"):
                return "Single date time error"
            val = val.replace("Z", "")
            t_record = datetime.strptime(val, '%Y-%m-%dT%H:%M:%S')
            if t_record.microsecond > 999:
                return "Single date time error"
            t_now = datetime.now()
            if t_record > t_now:
                return "Single date time error"
            return "OK - quality check"
        except ValueError:
            return "Single date time error"

    def checkTemporalBeginningTime(self, val):
        print "Input of checkTemporalBeginningTime() is " + val
        try:
            if val == None:
                return "np"
            if not val.endswith("Z"):
                return "Beginning date time error"
            val = val.replace("Z", "")
            t_record = datetime.strptime(val, '%Y-%m-%dT%H:%M:%S')
            if t_record.microsecond > 999:
                return "Beginning date time error"
            t_now = datetime.now()
            if t_record > t_now:
                return "Beginning date time error"
            return "OK - quality check"
        except ValueError:
            return "Beginning date time error"

    def checkTemporalEndingTime(self, val):
        print "Input of checkTemporalEndingTime() is " + val
        try:
            if val == None:
                return "np"
            if not val.endswith("Z"):
                return "Ending date time error"
            val = val.replace("Z", "")
            t_record = datetime.strptime(val, '%Y-%m-%dT%H:%M:%S')
            if t_record.microsecond > 999:
                return "Ending date time error"
            t_now = datetime.now()
            if t_record > t_now:
                return "Ending date time error"
            return "OK - quality check"
        except ValueError:
            return "Ending date time error"

    def checkBoundingRectangle(self, val):
        print "Input of checkBoundingRectangle() is ..."

        if val['WestBoundingCoordinate'] == None or val['NorthBoundingCoordinate'] == None or val['EastBoundingCoordinate'] == None or val['SouthBoundingCoordinate'] == None:
           return "Check for other spatial identifiers (Point; GPolygon; or Line). A spatial extent identifier is required., " + \
                  "Check for other spatial identifiers (Point; GPolygon; or Line). A spatial extent identifier is required., " + \
                  "Check for other spatial identifiers (Point; GPolygon; or Line). A spatial extent identifier is required., " + \
                  "Check for other spatial identifiers (Point; GPolygon; or Line). A spatial extent identifier is required., "

        msg = ''
        if float(val['WestBoundingCoordinate']) >= -180 and float(val['WestBoundingCoordinate']) <= 180:
            if float(val['EastBoundingCoordinate']) > float(val['WestBoundingCoordinate']):
                msg += "OK - quality check, "
            else:
                msg += "The East and West Bounding Coordinates may have been switched., "
        else:
            msg += "The coordinate does not fall within a valid range., "
        if float(val['NorthBoundingCoordinate']) >= -90 and float(val['NorthBoundingCoordinate']) <= 90:
            if float(val['SouthBoundingCoordinate']) < float(val['NorthBoundingCoordinate']):
                msg += "OK - quality check, "
            else:
                msg += "The North and South Bounding Coordinates may have been switched., "
        else:
            msg += "The coordinate does not fall within a valid range., "
        if float(val['EastBoundingCoordinate']) >= -180 and float(val['EastBoundingCoordinate']) <= 180:
            if float(val['EastBoundingCoordinate']) > float(val['WestBoundingCoordinate']):
                msg += "OK - quality check, "
            else:
                msg += "The East and West Bounding Coordinates may have been switched., "
        else:
            msg += "The coordinate does not fall within a valid range., "
        if float(val['SouthBoundingCoordinate']) >= -90 and float(val['SouthBoundingCoordinate']) <= 90:
            if float(val['SouthBoundingCoordinate']) < float(val['NorthBoundingCoordinate']):
                msg += "OK - quality check, "
            else:
                msg += "The North and South Bounding Coordinates may have been switched., "
        else:
            msg += "The coordinate does not fall within a valid range., "

        return msg

    def checkEquatorCrossingTime(self, val, length):
        print "Input of checkEquatorCrossingTime() is ..."
        if length == 1:
            try:
                if val == None:
                    return "np"
                if not val.endswith("Z"):
                    return "Time error"
                val = val.replace("Z", "")
                t_record = datetime.strptime(val, '%Y-%m-%dT%H:%M:%S')
                if t_record.microsecond > 999:
                    return "Time error"
                t_now = datetime.now()
                if t_record > t_now:
                    return "Time error"
                return "OK - quality check"
            except ValueError:
                return "Time error"        
        else:
            for i in range(0, length):
                try:
                    if val['EquatorCrossingDateTime'] == None:
                        return "np"
                    if not val['EquatorCrossingDateTime'].endswith("Z"):
                        return "Time error"
                    val['EquatorCrossingDateTime'] = val['EquatorCrossingDateTime'].replace("Z", "")
                    t_record = datetime.strptime(val['EquatorCrossingDateTime'], '%Y-%m-%dT%H:%M:%S')
                    if t_record.microsecond > 999:
                        return "Time error"
                    t_now = datetime.now()
                    if t_record > t_now:
                        return "Time error"
                    return "OK - quality check"
                except ValueError:
                    return "Time error"        

    def checkPlatformShortName(self, val, length):
        print "Input of checkPlatformShortName() is ..."
        PlatformKeys = list()
        PlatformLongNames = list()
        response = urllib2.urlopen(PlatformURL)
        data = csv.reader(response)
        next(data)  # Skip the first two line information
        next(data)
        for item in data:
            PlatformKeys += item[2:3]
            PlatformLongNames += item[3:4]
        PlatformKeys = list(set(PlatformKeys))
        PlatformLongNames = list(set(PlatformLongNames))
        response.close()

        if length == 1:
            if val == None:
                return "np"
            if val not in PlatformKeys:
                if val in PlatformLongNames:
                    return val + ": incorrect keyword order"
                else:
                    return "The keyword does not conform to GCMD"
        else:
            for i in range(0, length):
                if val[i]['ShortName'] == None:
                    return "np"
                if val[i]['ShortName'] not in PlatformKeys:
                    if val[i]['ShortName'] in PlatformLongNames:
                        return val[i]['ShortName'] + ": incorrect keyword order"
                    else:
                        return "The keyword does not conform to GCMD"
        return "OK - quality check"
        
    # def checkInstrShortName(self, val, platformNum):
    #     print "Input of checkInstrShortName() is ..."
    #     processInstrCount = 0
    #     InstrumentKeys = list()
    #     InstrumentLongNames = list()
    #     response = urllib2.urlopen(InstrumentURL)
    #     data = csv.reader(response)
    #     next(data)  # Skip the first two line information
    #     next(data)
    #     for item in data:
    #         if len(item) != 0:
    #             InstrumentKeys += item[4:5]
    #             InstrumentLongNames += item[5:6]
    #     InstrumentKeys = list(set(InstrumentKeys))
    #     InstrumentLongNames = list(set(InstrumentLongNames))
    #     response.close()

    #     if platformNum == 1:
    #         try:
    #             if val['Instruments']['Instrument']['ShortName'] == None:
    #                 return "np"
    #             if not any(s.lower() == val['Instruments']['Instrument']['ShortName'].lower() for s in InstrumentKeys):
    #                 if val['Instruments']['Instrument']['ShortName'] in InstrumentLongNames:
    #                     return val['Instruments']['Instrument'][instr]['ShortName'] + ": incorrect keyword order"
    #                 else:
    #                     return "The keyword does not conform to GCMD"
    #             processInstrCount += 1
    #         except TypeError:
    #             instrNum = len(val['Instruments']['Instrument'])
    #             for instr in range(0, instrNum):
    #                 if val['Instruments']['Instrument'][instr]['ShortName'] == None:
    #                     return "np"
    #                 if not any(s.lower() == val['Instruments']['Instrument'][instr]['ShortName'].lower() for s in InstrumentKeys):
    #                     if val['Instruments']['Instrument'][instr]['ShortName'] in InstrumentLongNames:
    #                         return val['Instruments']['Instrument'][instr]['ShortName'] + ": incorrect keyword order"
    #                     else:
    #                         return "The keyword does not conform to GCMD"
    #                 processInstrCount += 1
    #         except KeyError:
    #             print "Access Key Error!"
    #     else:
    #         for i in range(0, platformNum):
    #             try:
    #                 if val[i]['Instruments']['Instrument']['ShortName'] == None:
    #                     return "np"
    #                 if not any(s.lower() == val[i]['Instruments']['Instrument']['ShortName'].lower() for s in InstrumentKeys):
    #                     if val[i]['Instruments']['Instrument']['ShortName'] in InstrumentLongNames:
    #                         return val[i]['Instruments']['Instrument']['ShortName'] + ": incorrect keyword order"
    #                     else:
    #                         return "The keyword does not conform to GCMD"
    #                 processInstrCount += 1
    #             except TypeError:
    #                 instrNum = len(val[i]['Instruments']['Instrument'])
    #                 for instr in range(0, instrNum):
    #                     if val[i]['Instruments']['Instrument'][instr]['ShortName'] == None:
    #                         return "np"
    #                     if not any(s.lower() == val[i]['Instruments']['Instrument'][instr]['ShortName'].lower() for s in InstrumentKeys):
    #                         if val[i]['Instruments']['Instrument'][instr]['ShortName'] in InstrumentLongNames:
    #                             return val[i]['Instruments']['Instrument'][instr]['ShortName'] + ": incorrect keyword order"
    #                         else:
    #                             return "The keyword does not conform to GCMD"
    #                     processInstrCount += 1
    #             except KeyError:
    #                 continue
    #     if processInstrCount != 0:
    #         return "OK - quality check"
    #     else:
    #         return "np"
    
    def checkInstrShortName(self, val, platformNum, instruments):
        print "Input of checkInstrShortName() is ..."
        processInstrCount = 0
        InstrumentKeys = instruments[4]
        SensorResult = ''

        if platformNum == 1:
            try:
                # -------
                try:
                    val['Instruments']['Instrument']['Sensors']['Sensor']
                    if val['Instruments']['Instrument']['Sensors']['Sensor']['ShortName'] == val['Instruments']['Instrument']['ShortName']:
                        SensorResult = "Same as instrument. Consider removing since this is redundant information."
                except TypeError:
                    sensor_len = len(val['Instruments']['Instrument']['Sensors'])
                    for s in range(sensor_len):
                        try:
                            if val['Instruments']['Instrument']['Sensors'][s]['Sensor']['ShortName'] == val['Instruments']['Instrument']['ShortName']:
                                SensorResult = "Same as instrument. Consider removing since this is redundant information."
                                break
                        except KeyError:
                            continue
                except KeyError:
                    SensorResult = 'np'
                # if len(SensorResult) == 0:
                #     SensorResult = 'Recommend removing sensors from the metadata; since this field will be deprecated in the future.'
                # -------
                if val['Instruments']['Instrument']['ShortName'] == None:
                    return "np", SensorResult
                if not any(s.lower() == val['Instruments']['Instrument']['ShortName'].lower() for s in InstrumentKeys):
                    return "The keyword does not conform to GCMD.", SensorResult
                processInstrCount += 1
            except TypeError:
                instrNum = len(val['Instruments']['Instrument'])
                for instr in range(0, instrNum):
                    # -------
                    try:
                        val['Instruments']['Instrument'][instr]['Sensors']['Sensor']
                        if val['Instruments']['Instrument'][instr]['Sensors']['Sensor']['ShortName'] == val['Instruments']['Instrument'][instr]['ShortName']:
                            SensorResult = "Same as instrument. Consider removing since this is redundant information."
                    except TypeError:
                        sensor_len = len(val['Instruments']['Instrument'][instr]['Sensors'])
                        for s in range(sensor_len):
                            try:
                                if val['Instruments']['Instrument'][instr]['Sensors'][s]['Sensor']['ShortName'] == val['Instruments']['Instrument'][instr]['ShortName']:
                                    SensorResult = "Same as instrument. Consider removing since this is redundant information."
                                    break
                            except KeyError:
                                continue
                    except KeyError:
                        SensorResult = "np"
                    # if len(SensorResult) == 0:
                    #     SensorResult = 'Recommend removing sensors from the metadata; since this field will be deprecated in the future.'
                    # -------
                    if val['Instruments']['Instrument'][instr]['ShortName'] == None:
                        return "np", SensorResult
                    if not any(s.lower() == val['Instruments']['Instrument'][instr]['ShortName'].lower() for s in InstrumentKeys):
                        return "The keyword does not conform to GCMD.", SensorResult
                    processInstrCount += 1
            except KeyError:
                print "Access Key Error!"
        else:
            for i in range(0, platformNum):
                try:
                    # -------
                    try:
                        val[i]['Instruments']['Instrument']['Sensors']['Sensor']
                        if val[i]['Instruments']['Instrument']['Sensors']['Sensor']['ShortName'] == val[i]['Instruments']['Instrument']['ShortName']:
                            SensorResult = "Same as instrument. Consider removing since this is redundant information."
                    except TypeError:
                        sensor_len = len(val[i]['Instruments']['Instrument']['Sensors'])
                        for s in range(sensor_len):
                            try:
                                if val[i]['Instruments']['Instrument']['Sensors'][s]['Sensor']['ShortName'] == val[i]['Instruments']['Instrument']['ShortName']:
                                    SensorResult = "Same as instrument. Consider removing since this is redundant information."
                                    break
                            except KeyError:
                                SensorResult = "np"
                                continue
                    except KeyError:
                        SensorResult = "np"
                    # if len(SensorResult) == 0:
                    #     SensorResult = 'Recommend removing sensors from the metadata; since this field will be deprecated in the future.'
                    # -------
                    if val[i]['Instruments']['Instrument']['ShortName'] == None:
                        return "np", SensorResult
                    if not any(s.lower() == val[i]['Instruments']['Instrument']['ShortName'].lower() for s in InstrumentKeys):
                        return "The keyword does not conform to GCMD.", SensorResult
                    processInstrCount += 1
                except TypeError:
                    instrNum = len(val[i]['Instruments']['Instrument'])
                    for instr in range(0, instrNum):
                        # -------
                        try:
                            val[i]['Instruments']['Instrument'][instr]['Sensors']['Sensor']
                            if val[i]['Instruments']['Instrument'][instr]['Sensors']['Sensor']['ShortName'] == val[i]['Instruments']['Instrument'][instr]['ShortName']:
                                SensorResult = "Same as instrument. Consider removing since this is redundant information."
                        except TypeError:
                            sensor_len = len(val[i]['Instruments']['Instrument'][instr]['Sensors'])
                            for s in range(sensor_len):
                                try:
                                    if val[i]['Instruments']['Instrument'][instr]['Sensors'][s]['Sensor']['ShortName'] == val[i]['Instruments']['Instrument'][instr]['ShortName']:
                                        SensorResult = "Same as instrument. Consider removing since this is redundant information."
                                        break
                                except KeyError:
                                    continue
                        except KeyError:
                            SensorResult = "np"
                        # if len(SensorResult) == 0:
                        #     SensorResult = 'Recommend removing sensors from the metadata; since this field will be deprecated in the future.'
                        # -------
                        if val[i]['Instruments']['Instrument'][instr]['ShortName'] == None:
                            return "np", SensorResult
                        if not any(s.lower() == val[i]['Instruments']['Instrument'][instr]['ShortName'].lower() for s in InstrumentKeys):
                            return "The keyword does not conform to GCMD.", SensorResult
                        processInstrCount += 1
                except KeyError:
                    continue
        if processInstrCount != 0:
            return "OK- quality check", SensorResult
        else:
            return "np", SensorResult

    # def checkSensorShortName(self, val, platformNum):
    #     print "Input of checkInstrShortName() is ..."
    #     processInstrCount = 0
    #     SensorShortNames = list()
    #     SensorLongNames = list()
    #     response = urllib2.urlopen(InstrumentURL)
    #     data = csv.reader(response)
    #     next(data)  # Skip the first two line information
    #     next(data)
    #     for item in data:
    #         if len(item) != 0:
    #             SensorShortNames += item[4:5]
    #             SensorLongNames += item[5:6]
    #     SensorShortNames = list(set(SensorShortNames))
    #     SensorLongNames = list(set(SensorLongNames))
    #     response.close()


    def checkCampaignShortName(self, val, campaignNum):
        print "Input of checkCampaignShortName() is ..."
        CampaignKeys = list()
        CampaignLongNames = list()
        response = urllib2.urlopen(ProjectURL)
        data = csv.reader(response)
        next(data)  # Skip the first two line information
        next(data)
        for item in data:
            if len(item) != 0:
                CampaignKeys += item[1:2]
                CampaignLongNames += item[2:3]
        CampaignKeys = list(set(CampaignKeys))
        CampaignLongNames = list(set(CampaignLongNames))
        response.close()

        if campaignNum == 1:
            if val == None:
                return "np"
            elif val not in CampaignKeys:
                if val in CampaignLongNames:
                    return val + ": incorrect keyword order"
                else:
                    return "The keyword does not conform to GCMD."
            else:
                return "OK"
        else:
            for i in range(campaignNum):
                if val[i]['Campaign']['ShortName'] == None:
                    return "np"
                elif val[i]['Campaign']['ShortName'] not in CampaignKeys:
                    if val[i]['Campaign']['ShortName'] in CampaignLongNames:
                        return val[i]['Campaign']['ShortName'] + ": incorrect keyword order"
                    else:
                        return "The keyword does not conform to GCMD."
                else:
                    return "OK"


    def checkOnlineAccessURL(self, val, length):
        print "Input of checkOnlineAccessURL() is ..."
        brokenURLcount = 0
        msg = ""
        
        if length == 1:
            if val == None:
                return "np"
            try:
                connection = urllib2.urlopen(val)
                if connection:
                    realURL = connection.geturl()
                    connection.close()
                    if not realURL.startswith('https://urs.') and not realURL.startswith('http://urs.'):
                        return "Add a link to directly download the granule via URS."
            except (urllib2.HTTPError, urllib2.URLError) as e:
                return "The Online Access URL is a broken link"
        else:
            for i in range(0, length):
                if val[i]['URL'] == None:
                    return "np"
                try:
                    connection = urllib2.urlopen(val[i]['URL'])
                    if connection:
                        realURL = connection.geturl()
                        connection.close()
                        if not realURL.startswith('https://urs.') and not realURL.startswith('http://urs.'):
                            return "Add a link to directly download the granule via URS."
                except (urllib2.HTTPError, urllib2.URLError, socket.timeout) as e:
                    msg += "Broken link: " + val[i]['URL'] + ";"
                    brokenURLcount += 1
        if brokenURLcount != 0:
            return msg
        else:
            return "OK" 

    def checkOnlineAccessURLDesc(self, val, length):
        print "Input of checkOnlineAccessURLDesc() is ..."

        if length == 1:
            if val == None:
                return "Recommend providing descriptions for all Online Access URLs"
        else:
            for i in range(0, length):
                if val[i]['URLDescription'] == None:
                    return "Recommend providing descriptions for all Online Access URLs"
        return "OK - quality check" 

    def checkOnlineResourceURL(self, val, length):
        print "Input of checkOnlineResourceURL() is ..."
        brokenURLcount = 0
        msg = ""
        if length == 1:
            if val == None:
                return "np"
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
                        return "np"
                    connection = urllib2.urlopen(val[i]['URL'], timeout=5)
                    if connection:
                        connection.close()
                except (urllib2.HTTPError, urllib2.URLError, socket.timeout) as e:
                    msg += "Broken link: " + val[i]['URL'] + ";"
                    brokenURLcount += 1
        if brokenURLcount != 0:
            return msg
        else:
            return "OK"

    def checkOnlineResourceDesc(self, val, length):
        print "Input of checkOnlineResourceDesc() is ..."
        if length == 1:
            if val == None:
                return "np"
        else:
            for i in range(0, length):
                try:
                    if val[i]["Description"] == None:
                        return "np"
                except KeyError:
                    return "np"
        return "OK - quality check"

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
                return "Provide a URL type for all online resource URLs. Choose a type from the following list: http://gcmdservices.gsfc.nasa.gov/static/kms/rucontenttype/rucontenttype.csv"
            elif val not in ResourcesTypes:
                return "Invalid types: " + val + " URL Types are translated to GCMD vocabulary in CMR. In order to avoid translation errors; please choose an appropriate URL Content Type from the following keywords list: http://gcmdservices.gsfc.nasa.gov/static/kms/rucontenttype/rucontenttype.csv"
        else:
            for i in range(0, length):
                try:
                    if val[i]['URL'] != None:
                        try:
                            if val[i]['Type'] == None:
                                return "Provide a URL type for all online resource URLs. Choose a type from the following list: http://gcmdservices.gsfc.nasa.gov/static/kms/rucontenttype/rucontenttype.csv"
                            elif val[i]['Type'] not in ResourcesTypes:
                                return "Invalid types: " + val[i]['Type'] + " URL Types are translated to GCMD vocabulary in CMR. In order to avoid translation errors; please choose an appropriate URL Content Type from the following keywords list: http://gcmdservices.gsfc.nasa.gov/static/kms/rucontenttype/rucontenttype.csv"
                        except KeyError:
                            return "np"    
                except KeyError:
                    continue
        return "OK"

    def checkOrderable(self, val):
        print "Input of checkOrderable() is " + val
        if val == None:
            return "np"
        else:
            return "The Orderable field is being depreciated; and therefore can be removed from the metadata."

    def checkDataFormat(self, val):
        print "Input of checkDataFormat() is " + val
        if val == None:
            return "Recommend providing the data format(s) for this dataset"
        else:
            return "OK " + val

    def checkVisible(self, val):
        print "Input of checkVisible() is " + val
        if val == None:
            return "np"
        else:
            return "The Visible field is being depreciated; and therefore can be removed from the metadata."




x = Checker()
# print(sys.argv[1])
result, resultFields = x.checkAll(sys.argv[1])
# result, resultFields = x.checkAll("{\"ShortName\":\"CIESIN_SEDAC_NRMI_NRPCHI15\",\"VersionId\":\"2015.00\",\"InsertTime\":\"2016-11-02T00:00:00.000Z\",\"LastUpdate\":\"2016-11-02T00:00:00.000Z\",\"LongName\":\"Natural Resource Protection and Child Health Indicators, 2015 Release\",\"DataSetId\":\"Natural Resource Protection and Child Health Indicators, 2015 Release\",\"Description\":\"The Natural Resource Protection and Child Health Indicators, 2015 Release, are produced in support of the U.S. Millennium Challenge Corporation as selection criteria for funding eligibility. These indicators are successors to the Natural Resource Management Index (NRMI), which was produced from 2006 to 2011 and was based on the same underlying data. Like the NRMI, the Natural Resource Protection Indicator (NRPI) and Child Health Indicator (CHI) are based on proximity-to-target scores ranging from 0 to 100 (at target). The NRPI covers 221 countries and is calculated based on the weighted average percentage of biomes under protected status. The CHI is a composite index for 188 countries derived from the average of three proximity-to-target scores for access to improved sanitation, access to improved water, and child mortality. The 2015 release includes a consistent time series of NRPIs and CHIs for 2010 to 2015.\",\"CollectionDataType\":\"SCIENCE_QUALITY\",\"Orderable\":\"true\",\"Visible\":\"true\",\"RevisionDate\":\"2016-11-02T00:00:00.000Z\",\"ArchiveCenter\":\"SEDAC\",\"CollectionState\":\"Completed\",\"SpatialKeywords\":{\"Keyword\":[\"AFRICA\",\"ALGERIA\",\"ASIA\",\"AUSTRALIA\",\"BHUTAN\",\"BOTSWANA\",\"BURMA\",\"CAMBODIA\",\"CAMEROON\",\"CANADA\",\"CAPE VERDE\",\"CAYMAN ISLANDS\",\"CENTRAL AFRICAN REPUBLIC\",\"CHAD\",\"CHILE\",\"CHINA\",\"COLOMBIA\",\"COMOROS\",\"CONGO\",\"CONGO, DEMOCRATIC REPUBLIC\",\"COOK ISLANDS\",\"COSTA RICA\",\"COTE D'IVOIRE\",\"CROATIA\",\"CUBA\",\"CURACAO\",\"CYPRUS\",\"CZECH REPUBLIC\",\"DENMARK\",\"DJIBOUTI\",\"DOMINICA\",\"DOMINICAN REPUBLIC\",\"ECUADOR\",\"EGYPT\",\"EL SALVADOR\",\"EQUATORIAL\",\"EQUATORIAL GUINEA\",\"ERITREA\",\"ESTONIA\",\"ETHIOPIA\",\"EUROPE\",\"FAEROE ISLANDS\",\"FALKLAND ISLANDS\",\"FIJI\",\"FINLAND\",\"FRANCE\",\"FRENCH GUIANA\",\"FRENCH POLYNESIA\",\"GABON\",\"GAMBIA\",\"GEORGIA\",\"GERMANY\",\"GHANA\",\"GIBRALTAR\",\"GLOBAL\",\"GREECE\",\"GREENLAND\",\"GRENADA\",\"GUADELOUPE\",\"GUAM\",\"GUATEMALA\",\"GUINEA\",\"GUINEA-BISSAU\",\"GUYANA\",\"HAITI\",\"HONDURAS\",\"HONG KONG\",\"HUNGARY\",\"ICELAND\",\"INDIA\",\"INDONESIA\",\"IRAN\",\"IRAQ\",\"IRELAND\",\"ISLE OF MAN\",\"ISRAEL\",\"ITALY\",\"JAMAICA\",\"JAPAN\",\"JORDAN\",\"KAZAKHSTAN\",\"KENYA\",\"KIRIBATI\",\"KOSOVO\",\"KUWAIT\",\"KYRGYZSTAN\",\"LAO PEOPLE'S DEMOCRATIC REPUBLIC\",\"LATVIA\",\"LEBANON\",\"LESOTHO\",\"LIBERIA\",\"LIBYA\",\"LIECHTENSTEIN\",\"LITHUANIA\",\"LUXEMBOURG\",\"MACAU\",\"MACEDONIA\",\"MADAGASCAR\",\"MALAWI\",\"MALAYSIA\",\"MALDIVES\",\"MALI\",\"MALTA\",\"MARSHALL ISLANDS\",\"MARTINIQUE\",\"MAURITANIA\",\"MAURITIUS\",\"MAYOTTE\",\"MEXICO\",\"MICRONESIA\",\"MID-LATITUDE\",\"MOLDOVA\",\"MONACO\",\"MONGOLIA\",\"MONTENEGRO\",\"MONTSERRAT\",\"MOROCCO\",\"MOZAMBIQUE\",\"NAMIBIA\",\"NAURU\",\"NEPAL\",\"NETHERLANDS\",\"NEW CALEDONIA\",\"NEW ZEALAND\",\"NICARAGUA\",\"NIGER\",\"NIGERIA\",\"NIUE\",\"NORFOLK ISLAND\",\"NORTH AMERICA\",\"NORTH KOREA\",\"NORTHERN MARIANA ISLANDS\",\"NORWAY\",\"OMAN\",\"PAKISTAN\",\"PALAU\",\"PALESTINE\",\"PANAMA\",\"PAPUA NEW GUINEA\",\"PARAGUAY\",\"PERU\",\"PHILIPPINES\",\"PITCAIRN ISLANDS\",\"POLAND\",\"POLAR\",\"PORTUGAL\",\"PUERTO RICO\",\"QATAR\",\"REUNION\",\"ROMANIA\",\"RUSSIAN FEDERATION\",\"RWANDA\",\"SAMOA\",\"SAN MARINO\",\"SAO TOME AND PRINCIPE\",\"SAUDI ARABIA\",\"SENEGAL\",\"SERBIA\",\"SEYCHELLES\",\"SIERRA LEONE\",\"SINGAPORE\",\"SLOVAKIA\",\"SLOVENIA\",\"SOLOMON ISLANDS\",\"SOMALIA\",\"SOUTH AFRICA\",\"SOUTH AMERICA\",\"SOUTH KOREA\",\"SOUTH SUDAN\",\"SPAIN\",\"SRI LANKA\",\"ST HELENA\",\"ST KITTS AND NEVIS\",\"ST LUCIA\",\"ST MAARTEN\",\"ST MARTIN\",\"ST PIERRE AND MIQUELON\",\"ST VINCENT AND THE GRENADINES\",\"SUDAN\",\"SURINAME\",\"SVALBARD AND JAN MAYEN\",\"SWAZILAND\",\"SWEDEN\",\"SWITZERLAND\",\"SYRIAN ARAB REPUBLIC\",\"TAIWAN\",\"TAJIKISTAN\",\"TANZANIA\",\"THAILAND\",\"TIMOR-LESTE\",\"TOGO\",\"TOKELAU\",\"TONGA\",\"TRINIDAD AND TOBAGO\",\"TUNISIA\",\"TURKEY\",\"TURKMENISTAN\",\"TURKS AND CAICOS ISLANDS\",\"TUVALU\",\"UGANDA\",\"UKRAINE\",\"UNITED KINGDOM\",\"UNITED STATES OF AMERICA\",\"URUGUAY\",\"UZBEKISTAN\",\"VANUATU\",\"VENEZUELA\",\"VIETNAM\",\"VIRGIN ISLANDS\",\"WALLIS AND FUTUNA ISLANDS\",\"WESTERN SAHARA\",\"YEMEN\",\"ZAMBIA\",\"ZIMBABWE\"]},\"Temporal\":{\"RangeDateTime\":{\"BeginningDateTime\":\"2010-01-01T00:00:00.000Z\",\"EndingDateTime\":\"2015-12-31T23:59:59.999Z\"}},\"Contacts\":{\"Contact\":[{\"Role\":\"METADATA AUTHOR\",\"OrganizationEmails\":{\"Email\":\"metadata@ciesin.columbia.edu\"},\"ContactPersons\":{\"ContactPerson\":{\"FirstName\":\"unknown\",\"LastName\":\"CIESIN METADATA ADMINISTRATION\"}}},{\"Role\":\"TECHNICAL CONTACT\",\"OrganizationEmails\":{\"Email\":\"ciesin.info@ciesin.columbia.edu\"},\"ContactPersons\":{\"ContactPerson\":{\"FirstName\":\"unknown\",\"LastName\":\"SEDAC USER SERVICES\"}}}]},\"ScienceKeywords\":{\"ScienceKeyword\":[{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"BIOSPHERE\",\"TermKeyword\":\"ECOLOGICAL DYNAMICS\",\"VariableLevel1Keyword\":{\"Value\":\"COMMUNITY DYNAMICS\",\"VariableLevel2Keyword\":{\"Value\":\"BIODIVERSITY FUNCTIONS\"}}},{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"BIOSPHERE\",\"TermKeyword\":\"ECOSYSTEMS\",\"VariableLevel1Keyword\":{\"Value\":\"TERRESTRIAL ECOSYSTEMS\",\"VariableLevel2Keyword\":{\"Value\":\"ALPINE/TUNDRA\",\"VariableLevel3Keyword\":\"ALPINE TUNDRA\"}}},{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"BIOSPHERE\",\"TermKeyword\":\"ECOSYSTEMS\",\"VariableLevel1Keyword\":{\"Value\":\"TERRESTRIAL ECOSYSTEMS\",\"VariableLevel2Keyword\":{\"Value\":\"FORESTS\"}}},{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"HUMAN DIMENSIONS\",\"TermKeyword\":\"ENVIRONMENTAL IMPACTS\",\"VariableLevel1Keyword\":{\"Value\":\"CONSERVATION\"}},{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"HUMAN DIMENSIONS\",\"TermKeyword\":\"SUSTAINABILITY\",\"VariableLevel1Keyword\":{\"Value\":\"ENVIRONMENTAL SUSTAINABILITY\"}}]},\"Platforms\":{\"Platform\":{\"ShortName\":\"NOT APPLICABLE\",\"LongName\":null,\"Type\":\"Not applicable\",\"Instruments\":{\"Instrument\":{\"ShortName\":\"NOT APPLICABLE\"}}}},\"Campaigns\":{\"Campaign\":{\"ShortName\":\"NRMI\",\"LongName\":\"Natural Resources Management Index\"}},\"OnlineAccessURLs\":{\"OnlineAccessURL\":{\"URL\":\"http://sedac.ciesin.columbia.edu/data/set/nrmi-natural-resource-protection-child-health-indicators-2015/data-download\",\"URLDescription\":\"Data landing page\"}},\"Spatial\":{\"HorizontalSpatialDomain\":{\"Geometry\":{\"CoordinateSystem\":\"CARTESIAN\",\"BoundingRectangle\":{\"WestBoundingCoordinate\":\"-180\",\"NorthBoundingCoordinate\":\"90\",\"EastBoundingCoordinate\":\"180\",\"SouthBoundingCoordinate\":\"-55\"}}},\"GranuleSpatialRepresentation\":\"CARTESIAN\"}}")
print("result")
if result:
    print(result)
else
    print("none\n")    
print("resultFields")
# print(resultFields)
if resultFields:
    print(resultFields)
else
    print("none\n")  


