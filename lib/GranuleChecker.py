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

PlatformURL = "https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/platforms?format=csv"
InstrumentURL = "https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/instruments?format=csv"
ProjectURL = "https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/projects?format=csv"
ResourcesTypeURL = "https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/rucontenttype?format=csv"

import sys

import csv
import json
import urllib2

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


from CheckerGranule import checkerRules
from CSVGranule import GranuleOutputCSV
from JsonGranule import GranuleOutputJSON

class Checker():
    def __init__(self):
        self.checkerRules = checkerRules()
        self.fetchAllInstrs = fetchAllInstrs()
        self.granuleOutputCSV = GranuleOutputCSV(self.checkerRules,self.fetchAllInstrs)
        self.granuleOutputJSON = GranuleOutputJSON(self.checkerRules,self.fetchAllInstrs)

    def checkAll(self, metadata):
        metadata = metadata.replace("\\", "")
        metadata = json.loads(metadata)
        return self.granuleOutputCSV.checkAll(metadata)

    def checkAllJSON(self, metadata):
        metadata = metadata.replace("\\", "")
        metadata = json.loads(metadata)
        return self.granuleOutputJSON.checkAll(metadata)

x = Checker()

with open(sys.argv[1], 'r') as f:
    contents = f.read()
    resultFields = x.checkAllJSON(contents)
    print(json.dumps(resultFields))

