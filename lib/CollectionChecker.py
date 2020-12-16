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

import sys
import json

import csv
import urllib2

from CheckerCollection import checkerRules
from CSVCollection import CollectionOutputCSVBackup
from JsonCollection import CollectionOutputJSON

class Checker():

    def fetchAllSciKeyWords(self):
        #print "Fetch all Science Keywords ..."
        SciKeyWords = [[], [], [], [], [], [], []]
        # SciCategoryKeys, SciTopicKeys, SciTermKeys, SciVarL1Keys, SciVarL2Keys, SciVarL3Keys, SciDetailVar
        response = urllib2.urlopen(self.urls['ScienceKeywordURL'])
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

    def fetchAllPlatforms(self):
        #print "Fetch all Platforms ..."
        Platforms = [[], [], [], []]
        # Category, Series_Entity, Short_Name, Long_Name
        response = urllib2.urlopen(self.urls['PlatformURL'])
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

    def fetchAllInstrs(self):
        #print "Fetch all Instruments ..."
        InstrKeyWords = [[], [], [], [], [], []]
        # Category, SciTopicKeys, SciTermKeys, SciVarL1Keys, SciVarL2Keys, SciVarL3Keys, SciDetailVar
        response = urllib2.urlopen(self.urls['InstrumentURL'])
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

    def __init__(self):
        self.urls = {}

        self.urls['LocationKeywordURL'] = "https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/locations?format=csv"
        self.urls['ScienceKeywordURL'] = "https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/sciencekeywords?format=csv"
        self.urls['ArchiveCenterURL'] = "https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/providers?format=csv"
        self.urls['PlatformURL'] = "https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/platforms?format=csv"
        self.urls['InstrumentURL'] = "https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/instruments?format=csv"
        self.urls['ProjectURL'] = "https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/projects?format=csv"
        self.urls['ResourcesTypeURL'] = "https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/rucontenttype?format=csv"
        self.urls['ArchtoURLs'] = {'SEDAC': 'http://sedac.ciesin.columbia.edu/data/set/',
                              'GHRC': 'https://fcportal.nsstc.nasa.gov/pub',
                              'NSIDC': 'http://nsidc.org/data/',
                              'LPDAAC': 'https://lpdaac.usgs.gov/node/',
                              'ORNL_DAAC': 'http://daac.ornl.gov/cgi-bin/dsviewer.pl?ds_id',
                              'OB.DAAC': 'http://oceandata.sci.gsfc.nasa.gov/',
                              'Alaska Satellite Facility': 'https://vertex.daac.asf.alaska.edu/'}

        self.checkerRules = checkerRules(self.urls)
        # self.collectionOutputCSV = CollectionOutputCSV(self.checkerRules, self.fetchAllPlatforms, self.fetchAllInstrs,
        #                                                self.fetchAllSciKeyWords)
        self.collectionOutputJSON = CollectionOutputJSON(self.checkerRules, self.fetchAllPlatforms, self.fetchAllInstrs,
                                                         self.fetchAllSciKeyWords)

    def checkAll(self, metadata):
        metadata = metadata.replace("\\", "")
        metadata = json.loads(metadata)
        return self.collectionOutputJSON.checkAll(metadata)

    def checkAllJSON(self, metadata):
        metadata = metadata.replace("\\", "")
        metadata = json.loads(metadata)
        return self.collectionOutputJSON.checkAll(metadata)

x = Checker()

with open(sys.argv[1], 'r') as f:
    contents = f.read()
    resultFields = x.checkAll(contents)
    print(json.dumps(resultFields))

