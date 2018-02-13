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

class XmlListConfig(list):
    """
    Parse the xml as a python list
    """
    def __init__(self, aList):
        for element in aList:
            if len(element) > 0:
                if len(element) == 1 or element[0].tag != element[1].tag:
                    self.append(XmlDictConfig(element))
                elif element[0].tag == element[1].tag:
                    self.append(XmlListConfig(element))
            elif element.text:
                text = element.text.strip()
                if text:
                    self.append(text)


class XmlDictConfig(dict):
    """
    Parse the xml as a python dict
    """
    def __init__(self, parent_element):
        if parent_element.items():
            self.update(dict(parent_element.items()))
        for element in parent_element:
            if len(element) > 0:
                if len(element) == 1 or element[0].tag != element[1].tag:
                    aDict = XmlDictConfig(element)
                else:
                    aDict = {element[0].tag: XmlListConfig(element)}
                if element.items():
                    aDict.update(dict(element.items()))
                self.update({element.tag: aDict})

            elif element.items():
                self.update({element.tag: dict(element.items())})
            else:
                self.update({element.tag: element.text})

def buildDict(key, value):
    tmp = {}
    tmp[key] = value
    return tmp

def XmlDictConfigDIF(parent_element):
    if len(parent_element) == 0:
        return parent_element.text
    x = dict([])
    for element in parent_element:
        #print x.get(element.tag)
        if (type(x.get(element.tag)) is dict) or (type(x.get(element.tag)) is str):
            temp = []
            temp.append(x.get(element.tag))
            #print temp
            temp.append(XmlDictConfigDIF(element))
            x.update(buildDict(element.tag,temp))
            #print x.get(element.tag)
        elif(type(x.get(element.tag)) is list):
            temp = x.get(element.tag)
            temp.append(XmlDictConfigDIF(element))
            x.update(buildDict(element.tag,temp))
            #print x.get(element.tag)

        else:
            #print "else"
            x.update(buildDict(element.tag, XmlDictConfigDIF(element)))
    return x

from xml.etree import ElementTree

if __name__ == "__main__":

    filename = "MAI3CPASM"
    xml = ElementTree.parse(filename)

    root_element = xml.getroot()

    for collection in root_element.iter('DIF'):
        metadata = XmlDictConfigDIF(collection)
