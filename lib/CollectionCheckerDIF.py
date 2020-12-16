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

from CheckerDIF import checkerRules
from CSVDIF import DIFOutputCSV
from JsonDIF import DIFOutputJSON

class Checker():
    def __init__(self):
        self.checkerRules = checkerRules()
        self.DIFOutputCSV = DIFOutputCSV(self.checkerRules,self.wrap)
        self.DIFOutputJSON = DIFOutputJSON(self.checkerRules,self.wrap)

    def getItemList(self, items, keys):
        results = []
        if type(items) is not list:
            items = [items]
        if len(keys) == 0:
            return items
        for item in items:
            if item.has_key(keys[0]):
                results += self.getItemList(item[keys[0]], keys[1:])
            else:
                results += [None]
        return results

    def wrap(self, items, func, child):
        results = []
        keys = child.split('.')
        itemLst = self.getItemList(items, keys)
        for item in itemLst:
            #if item == None:
                #results.append('None')
            #else:
                results.append(func(item))
        return ';'.join(results)

    def checkAll(self, metadata):
        return self.DIFOutputCSV.checkAll(metadata)

    def checkAllJSON(self,metadata):
        return self.DIFOutputJSON.checkAll(metadata)

x = Checker()

with open(sys.argv[1], 'r') as f:
    contents = f.read()
    resultFields = x.checkAllJSON(contents)
    print(json.dumps(resultFields))

