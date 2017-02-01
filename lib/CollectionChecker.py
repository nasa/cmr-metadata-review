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

import json
import sys


import csv
import urllib2
import socket
import re
from collections import defaultdict
from datetime import *

LocationKeywordURL = "http://gcmdservices.gsfc.nasa.gov/static/kms/locations/locations.csv"
ScienceKeywordURL = "http://gcmdservices.gsfc.nasa.gov/static/kms/sciencekeywords/sciencekeywords.csv"
ArchiveCenterURL = "http://gcmdservices.gsfc.nasa.gov/static/kms/providers/providers.csv"
PlatformURL = "http://gcmdservices.gsfc.nasa.gov/static/kms/platforms/platforms.csv"
InstrumentURL = "http://gcmdservices.gsfc.nasa.gov/static/kms/instruments/instruments.csv"
ProjectURL = "http://gcmdservices.gsfc.nasa.gov/static/kms/projects/projects.csv"
ResourcesTypeURL = "http://gcmdservices.gsfc.nasa.gov/static/kms/rucontenttype/rucontenttype.csv"
ArchtoURLs = {'SEDAC':'http://sedac.ciesin.columbia.edu/data/set/', 
            'GHRC':'https://fcportal.nsstc.nasa.gov/pub',
            'NSIDC':'http://nsidc.org/data/',
            'LPDAAC':'https://lpdaac.usgs.gov/node/',
            'ORNL_DAAC':'http://daac.ornl.gov/cgi-bin/dsviewer.pl?ds_id',
            'OB.DAAC':'http://oceandata.sci.gsfc.nasa.gov/',
            'Alaska Satellite Facility':'https://vertex.daac.asf.alaska.edu/'}

def fetchAllSciKeyWords():
    #print "Fetch all Science Keywords ..."
    SciKeyWords = [[],[],[],[],[],[],[]]
    # SciCategoryKeys, SciTopicKeys, SciTermKeys, SciVarL1Keys, SciVarL2Keys, SciVarL3Keys, SciDetailVar
    response = urllib2.urlopen(ScienceKeywordURL)
    data = csv.reader(response)
    next(data)  # Skip the first two line information
    next(data)
    for item in data:
        SciKeyWords[0] += item[0:1]
        SciKeyWords[1] += item[1:2]
        SciKeyWords[2] += item[2:3]
        SciKeyWords[3] += item[3:4]
        SciKeyWords[4] += item[4:5]
        SciKeyWords[5] += item[5:6]
        SciKeyWords[6] += item[6:7]
    for i in range(7):
        SciKeyWords[i] = list(set(SciKeyWords[i]))
    response.close()
    return SciKeyWords

def fetchAllPlatforms():
    #print "Fetch all Platforms ..."
    Platforms = [[],[],[],[]]
    # Category, Series_Entity, Short_Name, Long_Name
    response = urllib2.urlopen(PlatformURL)
    data = csv.reader(response)
    next(data)  # Skip the first two line information
    next(data)
    for item in data:
        Platforms[0] += item[0:1]
        Platforms[1] += item[1:2]
        Platforms[2] += item[2:3]
        Platforms[3] += item[3:4]
    for i in range(4):
        Platforms[i] = list(set(Platforms[i]))
    response.close()
    return Platforms

def fetchAllInstrs():
    #print "Fetch all Instruments ..."
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
        

        try:
            #print("555")
            result = ""
            resultFields = ""

            metadata = json.loads(metadata)

            



            resultFields += 'ShortName' + ', '
            result += self.checkShortName(metadata['ShortName']) + ', '
            
            resultFields += 'VersionId' + ', '
            result += self.checkVersionID(metadata['VersionId']) + ', '
            # ================

            resultFields += 'InsertTime' + ', '
            try:
                result += self.checkInsertTime(metadata['InsertTime']) + ', '
            except KeyError:
                result += 'Provide an insert time for this dataset. This is a required field.' + ', '
            # ================

            resultFields += 'LastUpdate' + ', '
            try:
                result += self.checkLastUpdate(metadata['LastUpdate']) + ', '
            except KeyError:
                result += 'Provide a last update time for this dataset. This is a required field.' + ', '
            # ================

            resultFields += 'LongName' + ', '
            try:
                result += self.checkLongName(metadata['LongName']) + ', '
            except KeyError:
                result += 'np' + ', '
            # ================

            resultFields += 'DataSetId' + ', '
            try:
                result += self.checkDateSetID(metadata['DataSetId']) + ', '
            except KeyError:
                result += 'Provide a Dataset Id for this dataset. This is a required field.' + ', '
            # ================

            resultFields += 'Description' + ', '
            try:
                result += self.checkDesc(metadata['Description']) + ', , '
            except KeyError:
                result += 'Provide a description for this dataset. This is a required field.' + ', , '
            # ================
            resultFields += 'Orderable' + ', '
            try:
                result += self.checkOrderable(metadata['Orderable']) + ', '
            except KeyError:
                result += 'np' + ', '
            # ================
            resultFields += 'Visible' + ', '
            try:
                result += self.checkVisible(metadata['Visible']) + ', '
            except KeyError:
                result += 'np' + ', '
            # ================
            resultFields += 'RevisionDate' + ', '
            try:
                result += self.checkRevisionDate(metadata['RevisionDate']) + ', , '
            except KeyError:
                result += 'np' + ', , '
            # ================
            resultFields += 'ProcessingCenter' + ', '
            try:
                result += self.checkProcCenter(metadata['ProcessingCenter']) + ', '
            except KeyError:
                result += 'np' + ', '
            # ================
            resultFields += 'ProcessingLevelId' + ', '
            try:
                result += self.checkProcLevelID(metadata['ProcessingLevelId']) + ', , '
            except KeyError:
                result += 'Provide a processing level Id for this dataset. This is a required field.' + ', , '
            # ================
            resultFields += 'ArchiveCenter' + ', '
            try:
                result += self.checkArchiveCenter(metadata['ArchiveCenter']) + ', , '
            except KeyError:
                result += 'np' + ', , '
            # ================
            resultFields += 'CitationForExternalPublication' + ', '
            try:
                result += self.checkExtPub(metadata['CitationForExternalPublication']) + ', '
            except KeyError:
                result += 'np' + ', '
            # ================
            resultFields += 'CollectionState' + ', '
            try:
                result += self.checkCollectionState(metadata['CollectionState']) + ', , , , , '
            except KeyError:
                result += 'np' + ', , , , , '
            # ================
            # try:
            #     result += self.checkRestrictFlag(metadata['RestrictionFlag']) + ', , '
            # except KeyError:
            #     result += 'np' + ', , '
            # ================
            resultFields += 'DataFormat' + ', '
            try:
                result += self.checkDateFormat(metadata['DataFormat']) + ', '
            except KeyError:
                result += 'Recommend providing the data format(s) for this dataset.' + ', '
            # ================
            # try:
            #     result += self.checkPrice(metadata['Price']) + ', '
            # except KeyError:
            #     result += 'np' + ', '
            # ================
            resultFields += 'SpatialKeywords/Keyword' + ', '
            try:
                result += self.checkSpatialKey(metadata['SpatialKeywords']['Keyword']) + ', , , , , , , '
            except KeyError:
                result += 'Recommend providing a spatial keyword from the following keywords list: http://gcmdservices.gsfc.nasa.gov/static/kms/locations/locations.csv' + ', , , , , , , '
            # ================
            # try:
            #     result += self.checkTemporalKeyword(metadata['TemporalKeywords']['Keyword'], 1) + ', , , , , , '
            # except KeyError:
            #     if metadata['TemporalKeywords'] != None:
            #         length = len(metadata['TemporalKeywords'])
            #         result += self.checkTemporalKeyword(metadata['TemporalKeywords'], length) + ', , , , , , '
            #     else:
            #         result += 'np' + ', , , , , , '
            # ================
            resultFields += 'Temporal/SingleDateTime' + ', '
            try:
                result += self.checkSingleDateTime(metadata['Temporal']['SingleDateTime']) + ', '
            except KeyError:
                result += 'np' + ', '
            # ================
            try:
                result += self.checkBeginDateTime(metadata['Temporal']['RangeDateTime']['BeginningDateTime']) + ', '
            except KeyError:
                result += 'np' + ', '
            # ================
            try:
                result += self.checkEndDateTime(metadata['Temporal']['RangeDateTime']['EndingDateTime']) + ', , , , , , , , '    
            except KeyError:
                result += 'np' + ', , , , , , , , '    
            # ================
            try:
                result += self.checkContactRole(metadata['Contacts']['Contact']['Role']) + ', , , , , , , , , , , '
            except KeyError:
                result += 'np' + ', , , , , , , , , , , '
            # ================
            try:
                result += self.checkContactEmail(metadata['Contacts']['Contact']['OrganizationEmails']['Email'], 1) + ', , , , , '
            except KeyError:
                if metadata['Contacts']['Contact']['OrganizationEmails'] != None:
                    length = len(metadata['Contacts']['Contact']['OrganizationEmails'])
                    result += self.checkContactEmail(metadata['Contacts']['Contact']['OrganizationEmails'], length) + ', , , , , '
                else:
                    result += 'np' + ', , , , , '
            # ================
            ScienceKeywords = fetchAllSciKeyWords()
            try:
                result += self.checkSciKeyCategory(metadata['ScienceKeywords']['ScienceKeyword']['CategoryKeyword'], 1, ScienceKeywords) + ', '
            except TypeError:
                if metadata['ScienceKeywords'] != None:
                    length = len(metadata['ScienceKeywords']['ScienceKeyword'])
                    result += self.checkSciKeyCategory(metadata['ScienceKeywords']['ScienceKeyword'], length, ScienceKeywords) + ', '
                else:
                    result += 'Provide at least one science category keyword for this dataset. This is a required field.' + ', '
            except KeyError:
                result += 'Provide at least one science category keyword for this dataset. This is a required field.' + ', '
            # ================
            try:
                result += self.checkSciKeyTopic(metadata['ScienceKeywords']['ScienceKeyword']['TopicKeyword'], 1, ScienceKeywords) + ', '
            except TypeError:
                if metadata['ScienceKeywords'] != None:
                    length = len(metadata['ScienceKeywords']['ScienceKeyword'])
                    result += self.checkSciKeyTopic(metadata['ScienceKeywords']['ScienceKeyword'], length, ScienceKeywords) + ', '
                else:
                    result += 'Provide at least one science topic keyword for this dataset. This is a required field.' + ', '
            except KeyError:
                result += 'Provide at least one science topic keyword for this dataset. This is a required field.' + ', '
            # ================
            try:
                result += self.checkSciKeyTerm(metadata['ScienceKeywords']['ScienceKeyword']['TermKeyword'], 1, ScienceKeywords) + ', '
            except TypeError:
                if metadata['ScienceKeywords'] != None:
                    length = len(metadata['ScienceKeywords']['ScienceKeyword'])
                    result += self.checkSciKeyTerm(metadata['ScienceKeywords']['ScienceKeyword'], length, ScienceKeywords) + ', '
                else:
                    result += 'Provide at least one science term keyword for this dataset. This is a required field.' + ', '
            except KeyError:
                result += 'Provide at least one science term keyword for this dataset. This is a required field.' + ', '
            # ================
            try:
                result += self.checkSciKeyVarL1(metadata['ScienceKeywords']['ScienceKeyword']['VariableLevel1Keyword']['Value'], 1, ScienceKeywords) + ', '
            except TypeError:
                if metadata['ScienceKeywords'] != None:
                    length = len(metadata['ScienceKeywords']['ScienceKeyword'])
                    result += self.checkSciKeyVarL1(metadata['ScienceKeywords']['ScienceKeyword'], length, ScienceKeywords) + ', '
                else:
                    result += 'np' + ', '
            except KeyError:
                result += 'np' + ', '
            # ================
            try:
                result += self.checkSciKeyVarL2(metadata['ScienceKeywords']['ScienceKeyword']['VariableLevel1Keyword']['VariableLevel2Keyword']['Value'], 1, ScienceKeywords) + ', '
            except TypeError:
                if metadata['ScienceKeywords'] != None:
                    length = len(metadata['ScienceKeywords']['ScienceKeyword'])
                    result += self.checkSciKeyVarL2(metadata['ScienceKeywords']['ScienceKeyword'], length, ScienceKeywords) + ', '
                else:
                    result += 'np' + ', '
            except KeyError:
                result += 'np' + ', '
            # ================
            try:
                result += self.checkSciKeyVarL3(metadata['ScienceKeywords']['ScienceKeyword']['VariableLevel1Keyword']['VariableLevel2Keyword']['VariableLevel3Keyword']['Value'], 1, ScienceKeywords) + ', , '
            except TypeError:
                if metadata['ScienceKeywords'] != None:
                    length = len(metadata['ScienceKeywords']['ScienceKeyword'])
                    result += self.checkSciKeyVarL3(metadata['ScienceKeywords']['ScienceKeyword'], length, ScienceKeywords) + ', , '
                else:
                    result += 'np' + ', , '
            except KeyError:
                result += 'np' + ', , '
            # ================
            platforms = fetchAllPlatforms()
            PlatformShortName = []
            try:
                result += self.checkPlatformShortName(metadata['Platforms']['Platform']['ShortName'], 1, platforms) + ', '
                PlatformShortName += metadata['Platforms']['Platform']['ShortName']
            except TypeError:
                if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                    length = len(metadata['Platforms']['Platform'])
                    result += self.checkPlatformShortName(metadata['Platforms']['Platform'], length, platforms) + ', '
                    for i in range(length):
                        PlatformShortName += metadata['Platforms']['Platform'][i]['ShortName']
                else:
                    result += 'Provide at least one platform for this dataset. This is a required field.' + ', '
            except KeyError:
                result += 'Provide at least one platform for this dataset. This is a required field.' + ', '
            # ================
            try:
                result += self.checkPlatformLongName(metadata['Platforms']['Platform']['LongName'], 1, PlatformShortName, platforms) + ', '
            except TypeError:
                if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                    length = len(metadata['Platforms']['Platform'])
                    result += self.checkPlatformLongName(metadata['Platforms']['Platform'], length, PlatformShortName, platforms) + ', '
                else:
                    result += 'Recommend adding a platform long name, if applicable.' + ', '
            except KeyError:
                result += 'Recommend adding a platform long name, if applicable.' + ', '
            # ================
            try:
                metadata['Platforms']['Platform']['Type']
                result += self.checkPlatformType(metadata['Platforms']['Platform']['Type'], 1, platforms) + ', , , , , , '
            except TypeError:
                if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                    length = len(metadata['Platforms']['Platform'])
                    result += self.checkPlatformType(metadata['Platforms']['Platform'], length, platforms) + ', , , , , , '
                else:
                    result += 'Provide at least one platform for this dataset. This is a required field.' + ', , , , , , '
            except KeyError:
                    result += 'Provide at least one platform for this dataset. This is a required field.' + ', , , , , , '
            # ================
            instruments = fetchAllInstrs()
            sensorShortResult = ''
            try:
                metadata['Platforms']['Platform']['ShortName']
                platform_num = 1
                ret, sensorShortResult = self.checkInstrShortName(metadata['Platforms']['Platform'], platform_num, instruments)
                result += ret + ', '
            except TypeError:
                if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                    platform_num = len(metadata['Platforms']['Platform'])
                    ret, sensorShortResult = self.checkInstrShortName(metadata['Platforms']['Platform'], platform_num, instruments)
                    result += ret + ', '
                else:
                    result += 'Provide at least one relevant instrument for this dataset. This is a required field.' + ', '
            except KeyError:
                result += 'Provide at least one relevant instrument for this dataset. This is a required field.' + ', '
            # ================
            sensorLongResult = ''
            try:
                metadata['Platforms']['Platform']['LongName']
                platform_num = 1
                ret, sensorLongResult = self.checkInstrLongName(metadata['Platforms']['Platform'], platform_num, instruments)
                result += ret + ', , , , , , , , '
            except TypeError:
                if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                    platform_num = len(metadata['Platforms']['Platform'])
                    ret, sensorLongResult = self.checkInstrLongName(metadata['Platforms']['Platform'], platform_num, instruments)
                    result += ret + ', , , , , , , , '
                else:
                    result += 'Recommend providing an instrument long name; since many instrument long names are comprised of acronyms.' + ', , , , , , , , '
            except KeyError:
                result += 'Recommend providing an instrument long name; since many instrument long names are comprised of acronyms.' + ', , , , , , , , '
            # ================
            if len(sensorShortResult) == 0:
                result += 'np , '
            else:
                result += sensorShortResult + ', '
            # ================
            if len(sensorLongResult) == 0:
                result += 'np , , , , , , , , , , , , , , , , , , , , , , '
            else:
                result += sensorLongResult + ', , , , , , , , , , , , , , , , , , , , , , '
            # ================
            try:
                result += self.checkCampaignShortName(metadata['Campaigns']['Campaign']['ShortName'], 1) + ', '
            except TypeError:
                length = len(metadata['Campaigns']['Campaign'])
                result += self.checkCampaignShortName(metadata['Campaigns']['Campaign'], length) + ', '
            except KeyError:
                result += 'np' + ', '
            # ================
            try:
                result += self.checkCampaignLongName(metadata['Campaigns']['Campaign']['LongName'], 1) + ', '
            except TypeError:
                length = len(metadata['Campaigns']['Campaign'])
                result += self.checkCampaignLongName(metadata['Campaigns']['Campaign'], length) + ', '
            except KeyError:
                result += 'np' + ', '
            # ================
            try:
                result += self.checkCampaignStartDate(metadata['Campaigns']['Campaign']['StartDate'], 1) + ', '
            except TypeError:
                length = len(metadata['Campaigns']['Campaign'])
                result += self.checkCampaignStartDate(metadata['Campaigns']['Campaign'], length) + ', '
            except KeyError:
                result += 'np' + ', '
            # ================
            try:
                result += self.checkCampaignEndDate(metadata['Campaigns']['Campaign']['EndDate'], 1) + ', , , , , , '
            except TypeError:
                length = len(metadata['Campaigns']['Campaign'])
                result += self.checkCampaignEndDate(metadata['Campaigns']['Campaign'], length) + ', , , , , , '
            except KeyError:
                result += 'np' + ', , , , , , '
            # ================
            try:
                result += self.checkOnlineAccessURL(metadata['OnlineAccessURLs']['OnlineAccessURL']['URL'], 1, metadata['ArchiveCenter']) + ','
            except TypeError:
                if metadata['OnlineAccessURLs'] != None:
                    length = len(metadata['OnlineAccessURLs']['OnlineAccessURL'])
                    result += self.checkOnlineAccessURL(metadata['OnlineAccessURLs']['OnlineAccessURL'], length, metadata['ArchiveCenter']) + ','
                else:
                    result += 'np' + ','
            except KeyError:
                result += 'np' + ','
            # ================
            try:
                result += self.checkOnlineURLDesc(metadata['OnlineAccessURLs']['OnlineAccessURL']['Description'], 1) + ', ,'
            except TypeError:
                if metadata['OnlineAccessURLs'] != None:
                    length = len(metadata['OnlineAccessURLs']['OnlineAccessURL'])
                    result += self.checkOnlineURLDesc(metadata['OnlineAccessURLs']['OnlineAccessURL'], length) + ', ,'
                else:
                    result += 'Recommend providing descriptions for all Online Access URLs.' + ', , '
            except KeyError:
                result += 'Recommend providing descriptions for all Online Access URLs.' + ', ,'
            # ================
            try:
                result += self.checkOnlineResourceURL(metadata['OnlineResources']['OnlineResource']['URL'], 1) + ','
            except TypeError:
                if metadata['OnlineResources'] != None:
                    length = len(metadata['OnlineResources']['OnlineResource'])
                    result += self.checkOnlineResourceURL(metadata['OnlineResources']['OnlineResource'], length) + ','
                else:
                    result += 'np' + ','
            except KeyError:
                result += 'np' + ','
            # ================
            try:
                result += self.checkOnlineResourceURLDesc(metadata['OnlineResources']['OnlineResource']['Description'], 1) + ','
            except TypeError:
                if metadata['OnlineResources'] != None:
                    length = len(metadata['OnlineResources']['OnlineResource'])
                    result += self.checkOnlineResourceURLDesc(metadata['OnlineResources']['OnlineResource'], length) + ','
                else:
                    result += 'np' + ','
            except KeyError:
                result += 'np' + ','
            # ================
            try:
                result += self.checkOnlineResourceType(metadata['OnlineResources']['OnlineResource']['Type'], 1) + ', , , , , , , , '
            except TypeError:
                if metadata['OnlineResources'] != None:
                    length = len(metadata['OnlineResources']['OnlineResource'])
                    result += self.checkOnlineResourceType(metadata['OnlineResources']['OnlineResource'], length) + ', , , , , , , , '
                else:
                    result += 'np' + ', , , , , , , , '
            except KeyError:
                result += 'np' + ', , , , , , , , '
            # ================
            # result += self.checkSpatialHorGeoCoor(metadata['Spatial']['HorizontalSpatialDomain']['Geometry']['CoordinateSystem']) + ', '
            # ================
            result += self.checkBoundingRectangle(metadata['Spatial']['HorizontalSpatialDomain']['Geometry']['BoundingRectangle']) + ', , , , , , , , '
            # # ================
            # try:
            #     result += self.checkSpatialGranuleRepresent(metadata['Spatial']['GranuleSpatialRepresentation']) + ', , , , , , , , , , , '
            # except KeyError:
            #     result += 'Provide a granule spatial representation for this dataset. This is a required field.' + ', , , , , , , , , , , '
            # # ================
            # try:
            #     result += self.checkSpatInfoHorGeoDatumName(metadata['SpatialInfo']['HorizontalCoordinateSystem']['GeodeticModel']['HorizontalDatumName']) + ', '
            # except KeyError:
            #     result += 'np'
            return result, resultFields
        except:    
            return result, resultFields

    def checkShortName(self, val):
        #print 'Input of checkShortName() is ' + val
        if val == None:
            return 'Provide a short name for this dataset. This is a required field.'
        else:
            return 'OK'

    def checkVersionID(self, val):
        #print 'Input of checkVersionID() is ' + val
        if val == None:
            return 'Provide a version Id for this dataset. This is a required field.'
        else:
            return 'OK'

    def checkInsertTime(self, val):
        #print 'Input of checkInsertTime() is ' + val
        try:
            if val == None:
                return 'Provide an insert time for this dataset. This is a required field.'
            if not val.endswith('Z'):
                return 'Insert time error'
            val = val.replace('Z', '')
            t_record = datetime.strptime(val, '%Y-%m-%dT%H:%M:%S')
            if t_record.microsecond > 999:
                return 'Insert time error'
            t_now = datetime.now()
            if t_record > t_now:
                return 'Insert time error'
            return 'OK - quality check'
        except ValueError:
            return 'Insert time error'

    def checkLastUpdate(self, val):
        #print 'Input of checkLastUpdate() is ' + val
        try:
            if val == None:
                return 'Provide a last update time for this dataset. This is a required field.'
            elif not val.endswith('Z'):
                return 'Last update time error'
            val = val.replace('Z', '')
            t_record = datetime.strptime(val, '%Y-%m-%dT%H:%M:%S')
            if t_record.microsecond > 999:
                return 'Last update time error'
            t_now = datetime.now()
            if t_record > t_now:
                return 'Last update time error'
            return 'OK - quality check'
        except ValueError:
            return 'Last update time error'

    def checkLongName(self, val):
        #print "Input of checkLongName() is " + val
        if val == None:
            return "np"
        elif val.isupper() or val.islower():
            return "Recommend that the Long Name use mixed case to optimize human readability.."
        else:
            return "OK"

    def checkCollectionState(self, val):
        #print "Input of checkCollectionState() is " + val
        states = ('PLANNED', 'IN WORK', 'COMPLETE')
        if val == None:
            return "np"
        elif val not in states:
            return "Invalid value for Collection State. Please choose a valid Collection State from the following list: PLANNED; IN WORK; COMPLETE"
        else:
            return "OK"

    def checkDateSetID(self, val):
        #print "Input of checkDateSetID() is " + val
        if val == None:
            return "Provide a Dataset Id for this dataset. This is a required field."
        elif val.isupper() or val.islower():
            return "Recommend changing the Dataset Id to mixed case to improve human readability."
        else:
            return "OK"

    def checkDesc(self, val):
        #print "Input of checkDesc() is " + val[0:20]
        msg = ''
        if val == None:
            return "Provide a description for this dataset. This is a required field."
        if len(val) < 50:
            msg += "Dataset description may be inadequate, based on length."
        else:
            msg += "OK - quality check"

        urls = re.findall('http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+', val)
        for url in urls:
            try:
                connection = urllib2.urlopen(url)
                if connection:
                    connection.close()
            except (urllib2.HTTPError, urllib2.URLError) as e:
                msg += "Broken link: " + url

        if 'html' in val:
            msg += 'The description contains HTML. Please verify the HTML entities are being displayed properly.'
        return msg

    def checkOrderable(self, val):
        #print 'Input of checkOrderable() is ' + val
        if val == None:
            return 'np'
        else:
            return 'Note: The Orderable field is being deprecated in UMM.'

    def checkVisible(self, val):
        #print 'Input of checkVisible() is ' + val
        if val == None:
            return 'np'
        else:
            return 'Note: The Visible field is being deprecated in UMM.'

    def checkRevisionDate(self, val):
        #print 'Input of checkRevisionDate() is ' + val
        try:
            if val == None:
                return 'Provide an revision date for this dataset. This is a required field.'
            if not val.endswith('Z'):
                return 'Revision date error'
            val = val.replace('Z', '')
            t_record = datetime.strptime(val, '%Y-%m-%dT%H:%M:%S')
            if t_record.microsecond > 999:
                return 'Revision date error'
            t_now = datetime.now()
            if t_record > t_now:
                return 'Revision date error'
            return 'OK'
        except ValueError:
            return 'Revision date error'

    def checkProcCenter(self, val):
        #print 'Input of checkProcCenter() is ' + val
        DateCents = list()
        response = urllib2.urlopen(ArchiveCenterURL)
        data = csv.reader(response)
        next(data)  # Skip the first line information
        next(data)  
        for item in data:
            DateCents += item[4:5]

        if val == None:
            return 'np'
        elif val in DateCents:
            return "OK"
        else:
            return 'It is recommended that the Processing Center name be compliant with GCMD vocabulary. Choose a valid Processing Center name from the following list: http://gcmdservices.gsfc.nasa.gov/static/kms/providers/providers.csv All records from the same DAAC should have the same archive center name for consistency. \"Special CaseIf processing center = \"GHRC\": print \"Currently listed as \"GHRC.\" This field needs to follow vocabulary from the GCMD \"Data Centers\" keyword list: http://gcmdservices.gsfc.nasa.gov/static/kms/providers/providers.csv. According to GCMD the processing center should be listed as \"NASA/MSFC/GHRC.\" GCMD should be contacted for a change request if GHRC does not agree with this nomenclature.'

    def checkProcLevelID(self, val):
        #print 'Input of checkProcLevelID() is ' + val
        levels = ('0', '1A', '1B', '2', '3', '4')
        if val == None:
            return 'Provide a processing level Id for this dataset. This is a required field.'
        elif val == '1':
            return '\"\'1\' is not a valid Processing Level ID; please choose either \'1A\' or \'1B\'.\"'
        elif val not in levels:
            return 'Double check processing level I; invalid value'
        else:
            return 'OK'

    def checkArchiveCenter(self, val):
        #print "Input of checkArchiveCenter() is " + val
        ArchCents = list()
        response = urllib2.urlopen(ArchiveCenterURL)
        data = csv.reader(response)
        next(data)  # Skip the first line information
        next(data)  
        for item in data:
            ArchCents += item[4:5]
            # ArchCents += item[5:6]

        # ArchCents = ('ASDC', 'GESDISC', 'LARC', 'SEDAC', 'GHRC', 'NSIDC', 'LPDAAC', 'ORNL_DAAC', 'OB.DAAC', 'Alaska Satellite Facility', 'PO.DAAC', 'CDDIS', 'LAADS')
        if val == None:
            return 'np'
        elif val in ArchCents:
            return 'OK'
        else:
            return 'It is recommended that the Archive Center name be compliant with GCMD vocabulary. Choose a valid Archive Center name from the following list: http://gcmdservices.gsfc.nasa.gov/static/kms/providers/providers.csv All records from the same DAAC should have the same archive center name for consistency.'

    def checkExtPub(self, val):
        #print "Input of checkExtPub() is " + val
        if val == None:
            return "np"
        urls = re.findall('http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+', val)
        for url in urls:
            try:
                connection = urllib2.urlopen(url)
                if connection:
                    connection.close()
            except (urllib2.HTTPError, urllib2.URLError) as e:
                return "Broken link: " + url
        return "OK - quality check"

    def checkRestrictFlag(self, val):
        #print "Input of checkRestrictFlag() is " + val
        if val == None:
            return "np"
        else:
            return "OK - quality check"

    def checkDateFormat(self, val):
        #print "Input of checkDateFormat() is " + val
        if val == None:
            return "Recommend providing the data format(s) for this dataset."
        else:
            return "OK " + val

    def checkPrice(self, val):
        #print "Input of checkPrice() is " + val
        if val == None:
            return "np"
        else:
            return "OK"

    def checkSpatialKey(self, val):
        #print "Input of checkSpatialKey() is " + val
        if val == None:
            return "np"
        SpatialKeys = list()
        response = urllib2.urlopen(LocationKeywordURL)
        data = csv.reader(response)
        next(data)  # Skip the first line information
        for item in data:
            SpatialKeys += item[0:5]    # Skip UUID column
        SpatialKeys = list(set(SpatialKeys))
        response.close()

        if ', ' in val:
            for location in val.split(', '):
                if location not in SpatialKeys:
                    return "The spatial keyword " + location +" is not listed in GCMD or contains an error."
        else:
            if val not in SpatialKeys:
                return "The spatial keyword " + val +" is not listed in GCMD or contains an error."
        return "OK"

    def checkTemporalKeyword(self, val, length):
        #print "Input of checkTemporalKeyword() is ..."
        if length == 1:
            if len(val) != 0:
                return "OK - quality check"
        else:
            for i in range(0, length):
                if len(val[i][Keyword]) != 0:
                    return "OK - quality check"
        return "np"

    def checkSingleDateTime(self, val):
        #print "Input of checkSingleDateTime() is " + val
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

    def checkBeginDateTime(self, val):
        #print "Input of checkBeginDateTime() is " + val
        try:
            if val == None:
                return "Please provide an beginning date time for this dataset."
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

    def checkEndDateTime(self, val):
        #print "Input of checkEndDateTime() is " + val
        try:
            if val == None:
                return "Please provide an beginning date time for this dataset."
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

    def checkContactEmail(self, val, length):
        #print "Input of checkContactEmail() is ..." 
        if length == 1:
            if val == 'ghrc-dmg@itsc.uah.edu':
                return 'Please change from "ghrc-dmg@itsc.uah.edu" to "support-ghrc@earthdata.nasa.gov" since this is currently listed as the contact email on the GHRC website: https://ghrc.nsstc.nasa.gov/home/contact-us'
        else:
            for i in range(length):
                if val[i]['Email'] == 'ghrc-dmg@itsc.uah.edu':
                    return 'Please change from "ghrc-dmg@itsc.uah.edu" to "support-ghrc@earthdata.nasa.gov" since this is currently listed as the contact email on the GHRC website: https://ghrc.nsstc.nasa.gov/home/contact-us'
        return 'OK'

    def checkContactRole(self, val):
        #print "Input of checkContactRole() is " + val
        roles = ('PROCESSOR', 'ARCHIVER', 'DISTRIBUTOR', 'ORIGINATOR')
        if val == None:
            return "np"
        elif val not in roles:
            return 'Choose a contact role from the following list: ARCHIVER; DISTRIBUTOR; ORIGINATOR; PROCESSOR;'
        else:
            return "OK"

    def checkSciKeyCategory(self, val, length, sciKeyWords):
        #print "Input of checkSciKeyCategory() is ..."
        SciCategoryKeys = sciKeyWords[0]
        if length == 1:
            if val == None:
                return "np"
            if val not in SciCategoryKeys:
                for groupKeys in sciKeyWords:
                    if val in groupKeys:
                        return val + " is in the incorrect position of the science keyword hierarchy."        
                return "The keyword does not conform to GCMD."
        else:
            for i in range(0, length):
                if val[i]['CategoryKeyword'] == None:
                    return "np"
                if val[i]['CategoryKeyword'] not in SciCategoryKeys:
                    for groupKeys in sciKeyWords:
                        if val[i]['CategoryKeyword'] in groupKeys:
                            return val[i]['CategoryKeyword'] + " is in the incorrect position of the science keyword hierarchy."        
                    return "The keyword does not conform to GCMD."
        return "OK - quality check"

    def checkSciKeyTopic(self, val, length, sciKeyWords):    
        #print "Input of checkSciKeyTopic() is ..."
        SciTopicKeys = sciKeyWords[1]
        if length == 1:
            if val == None:
                return "Provide at least one science topic keyword for this dataset. This is a required field."
            if val not in SciTopicKeys:
                for groupKeys in sciKeyWords:
                    if val in groupKeys:
                        return val + " is in the incorrect position of the science keyword hierarchy."        
                return "Keyword does not conform to GCMD"
        else:
            for i in range(0, length):
                if val[i]['TopicKeyword'] == None:
                    return "Provide at least one science topic keyword for this dataset. This is a required field."
                if val[i]['TopicKeyword'] not in SciTopicKeys:
                    for groupKeys in sciKeyWords:
                        if val[i]['TopicKeyword'] in groupKeys:
                            return val[i]['TopicKeyword'] + " is in the incorrect position of the science keyword hierarchy."        
                    return "Keyword does not conform to GCMD"
        return "OK- quality check"

    def checkSciKeyTerm(self, val, length, sciKeyWords):
        #print "Input of checkSciKeyTerm() is ..."
        SciTermKeys = sciKeyWords[2]
        if length == 1:
            if val == None:
                return "Provide at least one science term keyword for this dataset. This is a required field."
            if val not in SciTermKeys:
                for groupKeys in sciKeyWords:
                    if val in groupKeys:
                        return val + " is in the incorrect position of the science keyword hierarchy."
                return "The science term keyword does not conform to GCMD"
        else:
            for i in range(0, length):
                if val[i]['TermKeyword'] == None:
                    return "Provide at least one science term keyword for this dataset. This is a required field."
                if val[i]['TermKeyword'] not in SciTermKeys:
                    for groupKeys in sciKeyWords:
                        if val[i]['TermKeyword'] in groupKeys:
                            return val[i]['TermKeyword'] + " is in the incorrect position of the science keyword hierarchy."
                    return "The science term keyword does not conform to gcmdservices"
        return "OK- quality check"

    def checkSciKeyVarL1(self, val, length, sciKeyWords):
        #print "Input of checkSciKeyVarL1() is ..."
        SciVarL1Keys = sciKeyWords[3]
        if length == 1:
            if val == None:
                return "np"
            if val not in SciVarL1Keys:
                return "The variable level 1 keyword does not conform to GCMD"
        else:
            for i in range(0, length):
                if val[i]['VariableLevel1Keyword']['Value'] == None:
                    return "np"
                if val[i]['VariableLevel1Keyword']['Value'] not in SciVarL1Keys:
                    for groupKeys in sciKeyWords:
                        if val[i]['VariableLevel1Keyword']['Value'] in groupKeys:
                            return val[i]['VariableLevel1Keyword']['Value'] + " is in the incorrect position of the science keyword hierarchy."
                    return "The variable level 1 keyword does not conform to GCMD"
        return "OK- quality check"

    def checkSciKeyVarL2(self, val, length, sciKeyWords):
        #print "Input of checkSciKeyVarL2() is ..."
        SciVarL2Keys = sciKeyWords[4]
        if length == 1:
            if val == None:
                return "np"
            if val not in SciVarL2Keys:
                return "The variable level 2 keyword does not conform to GCMD"
        else:
            try:
                for i in range(0, length):
                    if val[i]['VariableLevel1Keyword']['VariableLevel2Keyword']['Value'] == None:
                        return "np"
                    if val[i]['VariableLevel1Keyword']['VariableLevel2Keyword']['Value'] not in SciVarL2Keys:
                        for groupKeys in sciKeyWords:
                            if val[i]['VariableLevel1Keyword']['VariableLevel2Keyword']['Value'] in groupKeys:
                                return val[i]['VariableLevel1Keyword']['VariableLevel2Keyword']['Value'] + " is in the incorrect position of the science keyword hierarchy."
                        return "The variable level 2 keyword does not conform to GCMD"
            except KeyError:
                return "np"
        return "OK- quality check"

    def checkSciKeyVarL3(self, val, length, sciKeyWords):
        #print "Input of checkSciKeyVarL3() is ..."
        SciVarL3Keys = sciKeyWords[5]
        if length == 1:
            if val == None:
                return "np"
            if val not in SciVarL3Keys:
                return "The variable level 3 keyword does not conform to GCMD"
        else:
            try:
                for i in range(0, length):
                    if val[i]['VariableLevel1Keyword']['VariableLevel2Keyword']['VariableLevel3Keyword']['Value'] == None:
                        return "np"
                    if val[i]['VariableLevel1Keyword']['VariableLevel2Keyword']['VariableLevel3Keyword']['Value'] not in SciVarL3Keys:
                        for groupKeys in sciKeyWords:
                            if val[i]['VariableLevel1Keyword']['VariableLevel2Keyword']['VariableLevel3Keyword']['Value'] in groupKeys:
                                return val[i]['VariableLevel1Keyword']['VariableLevel2Keyword']['VariableLevel3Keyword']['Value'] + " is in the incorrect position of the science keyword hierarchy."
                        return "The variable level 3 keyword does not conform to GCMD"
            except KeyError:
                return "np"
        return "OK- quality check"

    def checkPlatformShortName(self, val, length, platforms):
        #print "Input of checkPlatformShortName() is ..."
        PlatformKeys = platforms[2]
        if length == 1:
            if val == None:
                return "np"
            if val not in PlatformKeys:
                for groupKeys in platforms:
                    if val in groupKeys:
                        return val + ": incorrect keyword order"
                return "The platform short name does not conform to GCMD."
        else:
            for i in range(0, length):
                if val[i]['ShortName'] == None:
                    return "np"
                if val[i]['ShortName'] not in PlatformKeys:
                    for groupKeys in platforms:
                        if val[i]['ShortName'] in groupKeys:
                            return val[i]['ShortName'] + ": incorrect keyword order"
                    return "The platform short name does not conform to GCMD."
        return "OK- quality check"

    def checkPlatformLongName(self, val, length, ShortNames, platforms):
        #print "Input of checkPlatformLongName() is ..."
        PlatformKeys = platforms[3]
        if length == 1:
            if val == None:
                return "Recommend adding a platform long name if applicable."
            if val not in PlatformKeys:
                for groupKeys in platforms:
                    if val in groupKeys:
                        return val + ": incorrect keyword order"
                return "The platform long name does not conform to GCMD."
            if val == ShortNames[0]:
                return 'Same as platform long name. Either replace with an appropriate long name or remove since this is redundant information.'
        else:
            for i in range(0, length):
                if val[i]['LongName'] == None:
                    return "Recommend adding a platform long name if applicable."
                if val[i]['LongName'] not in PlatformKeys:
                    for groupKeys in platforms:
                        if val[i]['LongName'] in groupKeys:
                            return val[i]['LongName'] + ": incorrect keyword order"
                    return "The platform long name does not conform to GCMD."
                if val[i]['LongName'] == ShortNames[i]:
                    return 'Same as platform long name. Either replace with an appropriate long name or remove since this is redundant information.'
        return "OK- quality check"

    def checkPlatformType(self, val, length, platforms):
        #print "Input of checkPlatformType() is ..."
        PlatformTypeKeys = platforms[0]
        if length == 1:
            if val == None:
                return 'Add a platform type. Each platform should have an associated type listed in the metadata.'
            # elif val == 'SATELLITE':
            #     return 'Change to \"Earth Observation Satellites\" to conform to GCMD keywords.'
            elif val == 'IN SITU LAND BASED':
                return 'Change to \"In Situ Land-based Platforms\" to conform to GCMD keywords.'
            elif val == 'AIRCRAFT':
                return 'Please change from \"AIRCRAFT\" to \"Aircraft\" to precisely match GCMD keywords. This will allow case sensitive programming languages to identify \"Aircraft\" as a GCMD keyword.'
            elif val not in PlatformTypeKeys:
                for groupKeys in platforms:
                    if val in groupKeys:
                        return val + ": incorrect keyword order"
                return 'The platform type does not conform to GCMD'
        else:
            for i in range(0, length):
                if val[i]['Type'] == None:
                    return 'Add a platform type. Each platform should have an associated type listed in the metadata.'
                # elif val[i]['Type'] == 'SATELLITE':
                #     return 'Change to \'Earth Observation Satellites\' to conform to GCMD Version 8.4 keywords.'
                elif val[i]['Type'] == 'IN SITU LAND BASED':
                    return 'Change to \'In Situ Land-based Platforms\' to conform to GCMD keywords.'
                elif val[i]['Type'] == 'AIRCRAFT':
                    return 'Please change from \"AIRCRAFT\" to \"Aircraft\" to precisely match GCMD keywords. This will allow case sensitive programming languages to identify \"Aircraft\" as a GCMD keyword.'
                elif val[i]['Type'] not in PlatformTypeKeys:
                    for groupKeys in platforms:
                        if val[i]['Type'] in groupKeys:
                            return val[i]['Type'] + ": incorrect keyword order"
                    return 'Platform Type does not conform to GCMD.'
        return 'OK- quality check'

    def checkInstrShortName(self, val, platformNum, instruments):
        #print "Input of checkInstrShortName() is ..."
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
                    return "Provide at least one relevant instrument for this dataset. This is a required field.", SensorResult
                if not any(s.lower() == val['Instruments']['Instrument']['ShortName'].lower() for s in InstrumentKeys):
                    return "The instrument short name does not conform to GCMD", SensorResult
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
                        return "Provide at least one relevant instrument for this dataset. This is a required field.", SensorResult
                    if not any(s.lower() == val['Instruments']['Instrument'][instr]['ShortName'].lower() for s in InstrumentKeys):
                        return "The instrument short name does not conform to GCMD", SensorResult
                    processInstrCount += 1
            except KeyError:
                #print "Access Key Error!"
                holder = 1
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
                        return "Provide at least one relevant instrument for this dataset. This is a required field.", SensorResult
                    if not any(s.lower() == val[i]['Instruments']['Instrument']['ShortName'].lower() for s in InstrumentKeys):
                        return "The instrument short name does not conform to GCMD", SensorResult
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
                            return "Provide at least one relevant instrument for this dataset. This is a required field.", SensorResult
                        if not any(s.lower() == val[i]['Instruments']['Instrument'][instr]['ShortName'].lower() for s in InstrumentKeys):
                            return "The instrument short name does not conform to GCMD", SensorResult
                        processInstrCount += 1
                except KeyError:
                    continue
        if processInstrCount != 0:
            return "OK- quality check", SensorResult
        else:
            return "Provide at least one relevant instrument for this dataset. This is a required field.", SensorResult

    def checkInstrLongName(self, val, platformNum, instruments):
        #print "Input of checkInstrLongName() is ..."
        processInstrCount = 0
        InstrumentKeys = instruments[5]
        SensorResult = ''

        if platformNum == 1:
            try:
                # -------
                try:
                    val['Instruments']['Instrument']['Sensors']['Sensor']
                    if val['Instruments']['Instrument']['Sensors']['Sensor']['LongName'] == val['Instruments']['Instrument']['LongName']:
                        SensorResult = "Same as instrument. Consider removing since this is redundant information."
                except TypeError:
                    sensor_len = len(val['Instruments']['Instrument']['Sensors'])
                    for s in range(sensor_len):
                        try:
                            if val['Instruments']['Instrument']['Sensors'][s]['Sensor']['LongName'] == val['Instruments']['Instrument']['LongName']:
                                SensorResult = "Same as instrument. Consider removing since this is redundant information."
                                break
                        except KeyError:
                            continue
                except KeyError:
                    SensorResult = 'np'
                # if len(SensorResult) == 0:
                #     SensorResult = 'Recommend removing sensors from the metadata; since this field will be deprecated in the future.'
                # -------
                if val['Instruments']['Instrument']['LongName'] == None:
                    return "Recommend providing an instrument long name; since many instrument short names are comprised of acronyms.", SensorResult
                if not any(s.lower() == val['Instruments']['Instrument']['LongName'].lower() for s in InstrumentKeys):
                    return "The instrument long name does not conform to GCMD", SensorResult
                processInstrCount += 1
            except TypeError:
                instrNum = len(val['Instruments']['Instrument'])
                for instr in range(0, instrNum):
                    # -------
                    try:
                        val['Instruments']['Instrument'][instr]['Sensors']['Sensor']
                        if val['Instruments']['Instrument'][instr]['Sensors']['Sensor']['LongName'] == val['Instruments']['Instrument'][instr]['LongName']:
                            SensorResult = "Same as instrument. Consider removing since this is redundant information."
                    except TypeError:
                        sensor_len = len(val['Instruments']['Instrument'][instr]['Sensors'])
                        for s in range(sensor_len):
                            try:
                                if val['Instruments']['Instrument'][instr]['Sensors'][s]['Sensor']['LongName'] == val['Instruments']['Instrument'][instr]['LongName']:
                                    SensorResult = "Same as instrument. Consider removing since this is redundant information."
                                    break
                            except KeyError:
                                continue
                    except KeyError:
                        SensorResult = "np"
                    # if len(SensorResult) == 0:
                    #     SensorResult = 'Recommend removing sensors from the metadata; since this field will be deprecated in the future.'
                    # -------
                    if val['Instruments']['Instrument'][instr]['LongName'] == None:
                        return "Recommend providing an instrument long name; since many instrument short names are comprised of acronyms.", SensorResult
                    if not any(s.lower() == val['Instruments']['Instrument'][instr]['LongName'].lower() for s in InstrumentKeys):
                        return "The instrument long name does not conform to GCMD", SensorResult
                    processInstrCount += 1
            except KeyError:
                #print "Access Key Error!"
                holder = 1
        else:
            for i in range(0, platformNum):
                try:
                    # -------
                    try:
                        val[i]['Instruments']['Instrument']['Sensors']['Sensor']
                        if val[i]['Instruments']['Instrument']['Sensors']['Sensor']['LongName'] == val[i]['Instruments']['Instrument']['LongName']:
                            SensorResult = "Same as instrument. Consider removing since this is redundant information."
                    except TypeError:
                        sensor_len = len(val[i]['Instruments']['Instrument']['Sensors'])
                        for s in range(sensor_len):
                            try:
                                if val[i]['Instruments']['Instrument']['Sensors'][s]['Sensor']['LongName'] == val[i]['Instruments']['Instrument']['LongName']:
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
                    if val[i]['Instruments']['Instrument']['LongName'] == None:
                        return "Recommend providing an instrument long name; since many instrument short names are comprised of acronyms.", SensorResult
                    if not any(s.lower() == val[i]['Instruments']['Instrument']['LongName'].lower() for s in InstrumentKeys):
                        return "The instrument long name does not conform to GCMD", SensorResult
                    processInstrCount += 1
                except TypeError:
                    instrNum = len(val[i]['Instruments']['Instrument'])
                    for instr in range(0, instrNum):
                        # -------
                        try:
                            val[i]['Instruments']['Instrument'][instr]['Sensors']['Sensor']
                            if val[i]['Instruments']['Instrument'][instr]['Sensors']['Sensor']['LongName'] == val[i]['Instruments']['Instrument'][instr]['LongName']:
                                SensorResult = "Same as instrument. Consider removing since this is redundant information."
                        except TypeError:
                            sensor_len = len(val[i]['Instruments']['Instrument'][instr]['Sensors'])
                            for s in range(sensor_len):
                                try:
                                    if val[i]['Instruments']['Instrument'][instr]['Sensors'][s]['Sensor']['LongName'] == val[i]['Instruments']['Instrument'][instr]['LongName']:
                                        SensorResult = "Same as instrument. Consider removing since this is redundant information."
                                        break
                                except KeyError:
                                    continue
                        except KeyError:
                            SensorResult = "np"
                        # if len(SensorResult) == 0:
                        #     SensorResult = 'Recommend removing sensors from the metadata; since this field will be deprecated in the future.'
                        # -------
                        if val[i]['Instruments']['Instrument'][instr]['LongName'] == None:
                            return "Recommend providing an instrument long name; since many instrument short names are comprised of acronyms.", SensorResult
                        if not any(s.lower() == val[i]['Instruments']['Instrument'][instr]['LongName'].lower() for s in InstrumentKeys):
                            return "The instrument long name does not conform to GCMD", SensorResult
                        processInstrCount += 1
                except KeyError:
                    continue
        if len(SensorResult) == 0:
            SensorResult = 'np'
        if processInstrCount != 0:
            return "OK- quality check", SensorResult
        else:
            return "Recommend providing an instrument long name; since many instrument short names are comprised of acronyms.", SensorResult

    def checkCampaignShortName(self, val, length):
        #print "Input of checkCampaignShortName() is ..."
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
                return "Provide a campaign name for this dataset. This is a required field."
            if val not in CampaignKeys:
                return "The campaign short name does not conform to GCMD"
        else:
            for i in range(0, length):
                if val[i]['ShortName'] == None:
                    return "Provide a campaign name for this dataset. This is a required field."
                if val[i]['ShortName'] not in CampaignKeys:
                    return "The campaign short name does not conform to GCMD"
        return "OK- quality check" 

    def checkCampaignLongName(self, val, length):
        #print "Input of checkCampaignLongName() is ..."
        CampaignKeys = list()
        response = urllib2.urlopen(ProjectURL)
        data = csv.reader(response)
        next(data)  # Skip the first two line information
        next(data)
        for item in data:
            CampaignKeys += item[2:3]
        CampaignKeys = list(set(CampaignKeys))
        response.close()
        if length == 1:
            if val == None:
                return "Recommend providing a campaign long name; if applicable."
            if val not in CampaignKeys:
                return "The campaign long name does not conform to GCMD"
        else:
            for i in range(0, length):
                if val[i]['LongName'] == None:
                    return "Recommend providing a campaign long name; if applicable."
                if val[i]['LongName'] not in CampaignKeys:
                    return "The campaign long name does not conform to GCMD"
        return "OK- quality check" 

    def checkCampaignStartDate(self, val, length):
        #print "Input of checkCampaignStartDate() is ..."
        try:
            if length == 1:
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
            else:
                for i in range(length):
                    if val[i]['StartDate'] == None:
                        return "np"
                    if not val[i]['StartDate'].endswith("Z"):
                        return "Single date time error"
                    val[i]['StartDate'] = val[i]['StartDate'].replace("Z", "")
                    t_record = datetime.strptime(val[i]['StartDate'], '%Y-%m-%dT%H:%M:%S')
                    if t_record.microsecond > 999:
                        return "Single date time error"
                    t_now = datetime.now()
                    if t_record > t_now:
                        return "Single date time error"
                return "OK - quality check"
        except ValueError:
            return "Single date time error"
        except KeyError:
            return "np"

    def checkCampaignEndDate(self, val, length):
        #print "Input of checkCampaignEndDate() is ..."
        try:
            if length == 1:
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
            else:
                for i in range(length):
                    if val[i]['EndDate'] == None:
                        return "np"
                    if not val[i]['EndDate'].endswith("Z"):
                        return "Single date time error"
                    val[i]['EndDate'] = val[i]['EndDate'].replace("Z", "")
                    t_record = datetime.strptime(val[i]['EndDate'], '%Y-%m-%dT%H:%M:%S')
                    if t_record.microsecond > 999:
                        return "Single date time error"
                    t_now = datetime.now()
                    if t_record > t_now:
                        return "Single date time error"
                return "OK - quality check"
        except ValueError:
            return "Single date time error"
        except KeyError:
            return "np"

    def checkOnlineAccessURL(self, val, length, ArchCenter):
        #print "Input of checkOnlineAccessURL() is ..."
        brokenURLcount = 0
        msg = ""
        try:
            url = ArchtoURLs[ArchCenter]
        except KeyError:
            url = ''
        if length == 1:
            if val == None:
                return "np"
            if not val.startswith(url):
                return 'Add a link to directly download the data via URS.'
            try:
                connection = urllib2.urlopen(val)
                if connection:
                    connection.close()
            except (urllib2.HTTPError, urllib2.URLError) as e:
                return "Broken link: " + val
        else:
            for i in range(0, length):
                if val[i]['URL'] == None:
                    return "np"
                if not val[i]['URL'].startswith(url):
                    return 'Add a link to directly download the data via URS.'
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
            return "OK" 

    def checkOnlineURLDesc(self, val, length):
        #print "Input of checkOnlineURLDesc() is ..."
        msg = ''
        if length == 1:
            if val == None:
                return "Recommend providing a URL description."
        else:
            for i in range(0, length):
                try:
                    if val[i]['Description'] == None:
                        return "Recommend providing descriptions for all Online Access URLs."
                except KeyError:      
                    return "Recommend providing descriptions for all Online Access URLs."  
        return "OK- quality check"

    def checkSpatialHorGeoCoor(self, val):
        #print "Input of checkSpatialHorGeoCoor() is " + val
        if val == None:
            return "np - Please provide a horizontal coordinate system for this dataset. This is a required field."
        else:
            return "OK"

    def checkBoundingRectangle(self, val):
        #print "Input of checkBoundingRectangle() is ..."
        msg = ''
        if val['WestBoundingCoordinate'] == None or val['NorthBoundingCoordinate'] == None or val['EastBoundingCoordinate'] == None or val['SouthBoundingCoordinate'] == None:
            return 'Check for other spatial identifiers (Point; GPolygon; or Line). A spatial extent identifier is required., ' + \
                   'Check for other spatial identifiers (Point; GPolygon; or Line). A spatial extent identifier is required., ' + \
                   'Check for other spatial identifiers (Point; GPolygon; or Line). A spatial extent identifier is required., ' + \
                   'Check for other spatial identifiers (Point; GPolygon; or Line). A spatial extent identifier is required., ' 

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

    def checkOnlineResourceURL(self, val, length):
        #print "Input of checkOnlineResourceURL() is ..."
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
                    # return "Broken link: " + val[i]['URL']
        if brokenURLcount != 0:
            return msg
        else:
            return "OK"

    def checkOnlineResourceURLDesc(self, val, length):
        #print "Input of checkOnlineResourceURLDesc() is ..."
        msg = ''
        if length == 1:
            if val == None:
                return "Recommend providing descriptions for all Online Resource URLs."
        else:
            for i in range(0, length):
                try:
                    if val[i]['Description'] == None:
                        return "Recommend providing descriptions for all Online Resource URLs."
                except KeyError:      
                    return "Recommend providing descriptions for all Online Resource URLs."
        return "OK- quality check"

    def checkOnlineResourceType(self, val, length):
        #print "Input of checkOnlineResourceType() is ..."
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
                return "Invalid types: " + val + ". URL Types are translated to GCMD vocabulary in CMR. In order to avoid translation errors please choose an appropriate URL Content Type from the following keywords list: http://gcmdservices.gsfc.nasa.gov/static/kms/rucontenttype/rucontenttype.csv"
        else:
            for i in range(0, length):
                try:
                    if val[i]['URL'] != None:
                        try:
                            if val[i]['Type'] == None:
                                return "Provide a URL type for all online resource URLs. Choose a type from the following list: http://gcmdservices.gsfc.nasa.gov/static/kms/rucontenttype/rucontenttype.csv"
                            elif val[i]['Type'] not in ResourcesTypes:
                                return "Invalid types: " + val[i]['Type'] + ". URL Types are translated to GCMD vocabulary in CMR. In order to avoid translation errors please choose an appropriate URL Content Type from the following keywords list: http://gcmdservices.gsfc.nasa.gov/static/kms/rucontenttype/rucontenttype.csv"
                        except KeyError:
                            return "np"    
                except KeyError:
                    continue
        return "OK"

    def checkSpatialGranuleRepresent(self, val):
        #print "Input of checkSpatialGranuleRepresent() is " + val
        represent_list = ('CARTESIAN', 'GEODETIC', 'ORBIT', 'NO_SPATIAL')
        if val == None:
            return "Provide a granule spatial representation for this dataset. This is a required field."
        elif val not in represent_list:
            return "The value for Granule Spatial Representation is invalid. Choose an appropriate replacement from the following list: CARTESIAN, GEODETIC, ORBIT, NO_SPATIAL"
        else:
            return "OK"

    def checkSpatInfoHorGeoDatumName(self, val):
        #print "Input of checkSpatInfoHorGeoDatumName() is " + val
        if val == None:
            return "np"
        else:
            return val






x = Checker()
# print(sys.argv[1])
result, resultFields = x.checkAll(sys.argv[1])
# result, resultFields = x.checkAll("{\"ShortName\":\"CIESIN_SEDAC_NRMI_NRPCHI15\",\"VersionId\":\"2015.00\",\"InsertTime\":\"2016-11-02T00:00:00.000Z\",\"LastUpdate\":\"2016-11-02T00:00:00.000Z\",\"LongName\":\"Natural Resource Protection and Child Health Indicators, 2015 Release\",\"DataSetId\":\"Natural Resource Protection and Child Health Indicators, 2015 Release\",\"Description\":\"The Natural Resource Protection and Child Health Indicators, 2015 Release, are produced in support of the U.S. Millennium Challenge Corporation as selection criteria for funding eligibility. These indicators are successors to the Natural Resource Management Index (NRMI), which was produced from 2006 to 2011 and was based on the same underlying data. Like the NRMI, the Natural Resource Protection Indicator (NRPI) and Child Health Indicator (CHI) are based on proximity-to-target scores ranging from 0 to 100 (at target). The NRPI covers 221 countries and is calculated based on the weighted average percentage of biomes under protected status. The CHI is a composite index for 188 countries derived from the average of three proximity-to-target scores for access to improved sanitation, access to improved water, and child mortality. The 2015 release includes a consistent time series of NRPIs and CHIs for 2010 to 2015.\",\"CollectionDataType\":\"SCIENCE_QUALITY\",\"Orderable\":\"true\",\"Visible\":\"true\",\"RevisionDate\":\"2016-11-02T00:00:00.000Z\",\"ArchiveCenter\":\"SEDAC\",\"CollectionState\":\"Completed\",\"SpatialKeywords\":{\"Keyword\":[\"AFRICA\",\"ALGERIA\",\"ASIA\",\"AUSTRALIA\",\"BHUTAN\",\"BOTSWANA\",\"BURMA\",\"CAMBODIA\",\"CAMEROON\",\"CANADA\",\"CAPE VERDE\",\"CAYMAN ISLANDS\",\"CENTRAL AFRICAN REPUBLIC\",\"CHAD\",\"CHILE\",\"CHINA\",\"COLOMBIA\",\"COMOROS\",\"CONGO\",\"CONGO, DEMOCRATIC REPUBLIC\",\"COOK ISLANDS\",\"COSTA RICA\",\"COTE D'IVOIRE\",\"CROATIA\",\"CUBA\",\"CURACAO\",\"CYPRUS\",\"CZECH REPUBLIC\",\"DENMARK\",\"DJIBOUTI\",\"DOMINICA\",\"DOMINICAN REPUBLIC\",\"ECUADOR\",\"EGYPT\",\"EL SALVADOR\",\"EQUATORIAL\",\"EQUATORIAL GUINEA\",\"ERITREA\",\"ESTONIA\",\"ETHIOPIA\",\"EUROPE\",\"FAEROE ISLANDS\",\"FALKLAND ISLANDS\",\"FIJI\",\"FINLAND\",\"FRANCE\",\"FRENCH GUIANA\",\"FRENCH POLYNESIA\",\"GABON\",\"GAMBIA\",\"GEORGIA\",\"GERMANY\",\"GHANA\",\"GIBRALTAR\",\"GLOBAL\",\"GREECE\",\"GREENLAND\",\"GRENADA\",\"GUADELOUPE\",\"GUAM\",\"GUATEMALA\",\"GUINEA\",\"GUINEA-BISSAU\",\"GUYANA\",\"HAITI\",\"HONDURAS\",\"HONG KONG\",\"HUNGARY\",\"ICELAND\",\"INDIA\",\"INDONESIA\",\"IRAN\",\"IRAQ\",\"IRELAND\",\"ISLE OF MAN\",\"ISRAEL\",\"ITALY\",\"JAMAICA\",\"JAPAN\",\"JORDAN\",\"KAZAKHSTAN\",\"KENYA\",\"KIRIBATI\",\"KOSOVO\",\"KUWAIT\",\"KYRGYZSTAN\",\"LAO PEOPLE'S DEMOCRATIC REPUBLIC\",\"LATVIA\",\"LEBANON\",\"LESOTHO\",\"LIBERIA\",\"LIBYA\",\"LIECHTENSTEIN\",\"LITHUANIA\",\"LUXEMBOURG\",\"MACAU\",\"MACEDONIA\",\"MADAGASCAR\",\"MALAWI\",\"MALAYSIA\",\"MALDIVES\",\"MALI\",\"MALTA\",\"MARSHALL ISLANDS\",\"MARTINIQUE\",\"MAURITANIA\",\"MAURITIUS\",\"MAYOTTE\",\"MEXICO\",\"MICRONESIA\",\"MID-LATITUDE\",\"MOLDOVA\",\"MONACO\",\"MONGOLIA\",\"MONTENEGRO\",\"MONTSERRAT\",\"MOROCCO\",\"MOZAMBIQUE\",\"NAMIBIA\",\"NAURU\",\"NEPAL\",\"NETHERLANDS\",\"NEW CALEDONIA\",\"NEW ZEALAND\",\"NICARAGUA\",\"NIGER\",\"NIGERIA\",\"NIUE\",\"NORFOLK ISLAND\",\"NORTH AMERICA\",\"NORTH KOREA\",\"NORTHERN MARIANA ISLANDS\",\"NORWAY\",\"OMAN\",\"PAKISTAN\",\"PALAU\",\"PALESTINE\",\"PANAMA\",\"PAPUA NEW GUINEA\",\"PARAGUAY\",\"PERU\",\"PHILIPPINES\",\"PITCAIRN ISLANDS\",\"POLAND\",\"POLAR\",\"PORTUGAL\",\"PUERTO RICO\",\"QATAR\",\"REUNION\",\"ROMANIA\",\"RUSSIAN FEDERATION\",\"RWANDA\",\"SAMOA\",\"SAN MARINO\",\"SAO TOME AND PRINCIPE\",\"SAUDI ARABIA\",\"SENEGAL\",\"SERBIA\",\"SEYCHELLES\",\"SIERRA LEONE\",\"SINGAPORE\",\"SLOVAKIA\",\"SLOVENIA\",\"SOLOMON ISLANDS\",\"SOMALIA\",\"SOUTH AFRICA\",\"SOUTH AMERICA\",\"SOUTH KOREA\",\"SOUTH SUDAN\",\"SPAIN\",\"SRI LANKA\",\"ST HELENA\",\"ST KITTS AND NEVIS\",\"ST LUCIA\",\"ST MAARTEN\",\"ST MARTIN\",\"ST PIERRE AND MIQUELON\",\"ST VINCENT AND THE GRENADINES\",\"SUDAN\",\"SURINAME\",\"SVALBARD AND JAN MAYEN\",\"SWAZILAND\",\"SWEDEN\",\"SWITZERLAND\",\"SYRIAN ARAB REPUBLIC\",\"TAIWAN\",\"TAJIKISTAN\",\"TANZANIA\",\"THAILAND\",\"TIMOR-LESTE\",\"TOGO\",\"TOKELAU\",\"TONGA\",\"TRINIDAD AND TOBAGO\",\"TUNISIA\",\"TURKEY\",\"TURKMENISTAN\",\"TURKS AND CAICOS ISLANDS\",\"TUVALU\",\"UGANDA\",\"UKRAINE\",\"UNITED KINGDOM\",\"UNITED STATES OF AMERICA\",\"URUGUAY\",\"UZBEKISTAN\",\"VANUATU\",\"VENEZUELA\",\"VIETNAM\",\"VIRGIN ISLANDS\",\"WALLIS AND FUTUNA ISLANDS\",\"WESTERN SAHARA\",\"YEMEN\",\"ZAMBIA\",\"ZIMBABWE\"]},\"Temporal\":{\"RangeDateTime\":{\"BeginningDateTime\":\"2010-01-01T00:00:00.000Z\",\"EndingDateTime\":\"2015-12-31T23:59:59.999Z\"}},\"Contacts\":{\"Contact\":[{\"Role\":\"METADATA AUTHOR\",\"OrganizationEmails\":{\"Email\":\"metadata@ciesin.columbia.edu\"},\"ContactPersons\":{\"ContactPerson\":{\"FirstName\":\"unknown\",\"LastName\":\"CIESIN METADATA ADMINISTRATION\"}}},{\"Role\":\"TECHNICAL CONTACT\",\"OrganizationEmails\":{\"Email\":\"ciesin.info@ciesin.columbia.edu\"},\"ContactPersons\":{\"ContactPerson\":{\"FirstName\":\"unknown\",\"LastName\":\"SEDAC USER SERVICES\"}}}]},\"ScienceKeywords\":{\"ScienceKeyword\":[{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"BIOSPHERE\",\"TermKeyword\":\"ECOLOGICAL DYNAMICS\",\"VariableLevel1Keyword\":{\"Value\":\"COMMUNITY DYNAMICS\",\"VariableLevel2Keyword\":{\"Value\":\"BIODIVERSITY FUNCTIONS\"}}},{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"BIOSPHERE\",\"TermKeyword\":\"ECOSYSTEMS\",\"VariableLevel1Keyword\":{\"Value\":\"TERRESTRIAL ECOSYSTEMS\",\"VariableLevel2Keyword\":{\"Value\":\"ALPINE/TUNDRA\",\"VariableLevel3Keyword\":\"ALPINE TUNDRA\"}}},{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"BIOSPHERE\",\"TermKeyword\":\"ECOSYSTEMS\",\"VariableLevel1Keyword\":{\"Value\":\"TERRESTRIAL ECOSYSTEMS\",\"VariableLevel2Keyword\":{\"Value\":\"FORESTS\"}}},{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"HUMAN DIMENSIONS\",\"TermKeyword\":\"ENVIRONMENTAL IMPACTS\",\"VariableLevel1Keyword\":{\"Value\":\"CONSERVATION\"}},{\"CategoryKeyword\":\"EARTH SCIENCE\",\"TopicKeyword\":\"HUMAN DIMENSIONS\",\"TermKeyword\":\"SUSTAINABILITY\",\"VariableLevel1Keyword\":{\"Value\":\"ENVIRONMENTAL SUSTAINABILITY\"}}]},\"Platforms\":{\"Platform\":{\"ShortName\":\"NOT APPLICABLE\",\"LongName\":null,\"Type\":\"Not applicable\",\"Instruments\":{\"Instrument\":{\"ShortName\":\"NOT APPLICABLE\"}}}},\"Campaigns\":{\"Campaign\":{\"ShortName\":\"NRMI\",\"LongName\":\"Natural Resources Management Index\"}},\"OnlineAccessURLs\":{\"OnlineAccessURL\":{\"URL\":\"http://sedac.ciesin.columbia.edu/data/set/nrmi-natural-resource-protection-child-health-indicators-2015/data-download\",\"URLDescription\":\"Data landing page\"}},\"Spatial\":{\"HorizontalSpatialDomain\":{\"Geometry\":{\"CoordinateSystem\":\"CARTESIAN\",\"BoundingRectangle\":{\"WestBoundingCoordinate\":\"-180\",\"NorthBoundingCoordinate\":\"90\",\"EastBoundingCoordinate\":\"180\",\"SouthBoundingCoordinate\":\"-55\"}}},\"GranuleSpatialRepresentation\":\"CARTESIAN\"}}")
print("result")
print(result)
print("resultFields")
print(resultFields)
