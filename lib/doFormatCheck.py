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

import os, errno
import CollectionChecker
import GranuleChecker
from cmr import searchCollection
from cmr import searchGranule
from xml.etree import ElementTree
from xmlParser import XmlDictConfig
from collections import OrderedDict
import csv
import re

# collection_output_header = "ECHO10 Collection Elements,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Spatial Info,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n\
# * = GCMD controlled: http://gcmd.nasa.gov/learn/keyword_list.html,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Platforms/ Platform Platforms/ Platform Platforms/ Platform,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Spatial,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Spatial Info/ Horizontal Coordinate System,,,,,,,,,,,,,,,,,,,,,,,,,\n\
# ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Platforms/ Platform/ Instruments/ Instrument,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Spatial/ Horizontal Spatial Domain,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Spatial Info/ Horizontal Coordinate System/ Planar Coordinate Systems/ Planar Coordinate System,,,,,,,,,,,,,,,,,,\n\
# ,,,,,,,,,,,,,,,,,,,,,,,,,,,Temporal,,,,,,,,,,,,,,,,Contacts/ Contact,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Platforms/ Platform/ Instruments/ Instrument/ Sensors/ Sensor,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,TwoD Coordinate Systems/ TwoD Coordinate System,,,,,,,,,,*Need to add mime type field + check whether there is an enum list for acceptable mime types,,,,,Spatial/ Horizontal Spatial Domain/ Geometry Spatial/ Horizontal Spatial Domain/ Geometry,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Spatial Info/ Vertical Coordinate System,,,,,,,,,,,,,,,,Spatial Info/ Horizontal Coordinate System/ Planar Coordinate Systems/ Planar Coordinate System/ Planar Coordinate Information,,,,,,,,,,,,,,,,,\n\
# ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Temporal/ Range Date Time,,Temporal/ Periodic Date Time,,,,,,,,,,,Contacts/ Contact/ Organization Addresses/ Address,,,,,Contacts/ Contact/ Organization Phones/ Phone,,,Contacts/ Contact/ Contact Persons/ Contact Person,,,,Science Keywords/ Science Keyword,,,,,,,,,,Platforms/ Platform/ Characteristics/ Characteristic,,,,,,,,,Platforms/ Platform/ Instruments/ Instrument/ Instrument Characteristics/ Characteristic,,,,,,,,Platform/ Instrument/ Sensors/ Sensor/ Sensor Characteristics/ Characteristic,,,,,,Additional Attributes/ Additional Attribute,,,,,,,,,,,,,,Collection Associations/ Collection Association,,,,Campaigns/ Campaign,,,,,TwoD Coordinate Systems/ TwoD Coordinate System/ Coordinate 1,,TwoD Coordinate Systems/ TwoD Coordinate System/ Coordinate 2,,Online Access URLs/ Online Access URL,,,Online Resources/ Online Resource,,,,,,,,Spatial/ Horizontal Spatial Domain/ Geometry/ Point,,Spatial/ Horizontal Spatial Domain/ Geometry/ Bounding Rectangle,,,,,,Spatial/ Horizontal Spatial Domain/ Geometry/ GPolygon,,,,,,Spatial/ Horizontal Spatial Domain/ Geometry/ Line,,,,Spatial/ Vertical Spatial Domain,,Spatial/ Orbit Parameters,,,,,,,,,Provider Browse URLs/ Provider Browse URL,,,,,Spatial Info/ Vertical Coordinate System/ Altitude System Definition,,,,Spatial Info/ Vertical Coordinate System/ Depth System Definition,,,,Spatial Info/ Horizontal Coordinate System/ Geodetic Model,,,,Spatial Info/ Horizontal Coordinate System/ Geographic Coordinate System,,,,,,Spatial Info/ Horizontal Coordinate System/ Planar Coordinate Systems/ Planar Coordinate System/ Planar Coordinate Information/ Distance and Bearing Representation,,,,,Spatial Info/ Horizontal Coordinate System/ Planar Coordinate Systems/ Planar Coordinate System/ Planar Coordinate Information/ Coordinate Representation,,Spatial Info/ Horizontal Coordinate System/ Planar Coordinate System/ Map Projection,,Spatial Info/ Horizontal Coordinate System/ Planar Coordinate System/ Local Planar Coordinate System,,,Spatial Info/ Horizontal Coordinate System/ Local Coordinate System,,,\n\
collection_output_header ="Dataset Id (short name) - umm-json link,Short Name,Version Id,Insert Time,Last Update,Long Name,Data Set Id,Description,DOI/DOI,DOI/Authority,Collection Data Type,Orderable,Visible,Revision Date,Suggested Usage,Processing Center *,Processing Level Id,Processing Level Description,Archive Center *,Version Description,Citation For External Publication,Collection State,Maintenance And Update Frequency,Restriction Flag,Restriction Comment,Price,Data Format,Spatial Keywords/ Keyword *,Temporal Keywords/ Keyword,Temporal/ Time Type,Temporal/ Date Type,Temporal/ Temporal Range Type,Temporal/ Precision of Seconds,Temporal/ Ends at Present Flag,Temporal/ Single Date Time,Temporal/ Range Date Time/ Beginning Date Time,Temporal/ Range Date Time/ Ending Date Time,Temporal/ Periodic Date Time/ Name,Temporal/ Periodic Date Time/ Start Date,Temporal/ Periodic Date Time/ End Date,Temporal/ Periodic Date Time/ Duration Unit,Temporal/ Periodic Date Time/ Duration Value,Temporal/ Periodic Date Time/ Period Cycle Duration Unit,Temporal/ Periodic Date Time/ Period Cycle Duration Value,Contacts/ Contact/ Role,Contacts/ Contact/ Hours of Service,Contacts/ Contact/ Instructions,Contacts/ Contact/ Organization Name,Contacts/ Contact/ Organization Addresses/ Address/ Street Address,Contacts/ Contact/ Organization Addresses/ Address/ City,Contacts/ Contact/ Organization Addresses/ Organization Address/ State Province,Contacts/ Contact/ Organization Addresses/ Address/ Postal Code,Contacts/ Contact/ Organization Addresses/ Address/ Country,Contacts/ Contact/ Organization Phones/ Phone/ Number,Contacts/ Contact/ Organization Phones,Contacts/ Contact/ Organization Emails/ Email,Contacts/ Contact/ Contact Persons/ Contact Person/ First Name,Contacts/ Contact/ Contact Persons/ Contact Person/ Middle Name,Contacts/ Contact/ Contact Persons/ Contact Person/ Last Name,Contacts/ Contact/ Contact Persons/ Contact Person,Science Keywords/ Science Keyword/ Category Keyword *,Science Keywords/ Science Keyword/ Topic Keyword*,Science Keywords/ Science Keyword/ Term Keyword*,Science Keywords/ Science Keyword/ Variable Level 1 Keyword/ Value *,Science Keywords/ Science Keyword/ Variable Level 1 Keyword/ Variable Level 2 Keyword/ Value *,Science Keywords/ Science Keyword/ Variable Level 1 Keyword/ Variable Level 2 Keyword/ Variable Level 3 Keyword/ Value *,Science Keywords/ Science Keyword/ Detailed Variable Keyword,Platforms/ Platform/ Short Name *,Platforms/ Platform/ Long Name *,Platforms/ Platform/ Type *,Platforms/ Platform/ Characteristics/ Characteristic/ Name,Platforms/ Platform/ Characteristics/ Characteristic/ Description,Platforms/ Platform/ Characteristics/ Characteristic/ Data Type,Platforms/ Platform/ Characteristics/ Characteristic/ Unit,Platforms/ Platform/ Characteristics/ Characteristic/ Value,Platforms/ Platform/ Instruments/ Instrument/ Short Name *,Platforms/ Platform/ Instruments/ Instrument/ Long Name *,Platforms/ Platform/ Instruments/ Instrument/ Technique,Platforms/ Platform/ Instruments/ Instrument/ Number of Sensors,Platforms/ Platform/ Instruments/ Instrument/ Instrument Characteristics/ Characteristic/ Name,Platforms/ Platform/ Instruments/ Instrument/ Instrument Characteristics/ Characteristic/ Description,Platforms/ Platform/ Instruments/ Instrument/ Instrument Characteristics/ Characteristic/ Data Type,Platforms/ Platform/ Instruments/ Instrument/ Instrument Characteristics/ Characteristic/ Unit,Platforms/ Platform/ Instruments/ Instrument/ Instrument Characteristics/ Characteristic/ Value,Platforms/ Platform/ Instruments/ Instrument/ Sensors/ Sensor/ Short Name *,Platforms/ Platform/ Instruments/ Instrument/ Sensors/ Sensor/ Long Name *,Platforms/ Platform/ Instruments/ Instrument/ Sensors/ Sensor/ Technique,Platform/ Instrument/ Sensors/ Sensor/ Sensor Characteristics/ Characteristic/ Name,Platform/ Instrument/ Sensors/ Sensor/ Sensor Characteristics/ Characteristic/ Description,Platform/ Instrument/ Sensors/ Sensor/ Sensor Characteristics/ Characteristic/ Data Type,Platform/ Instrument/ Sensors/ Sensor/ Sensor Characteristics/ Characteristic/ Unit,Platform/ Instrument/ Sensors/ Sensor/ Sensor Characteristics/ Characteristic/ Value,Platforms/ Platform/ Instruments/ Instrument/ Operation Modes/ Operation Mode,Additional Attributes/ Additional Attribute/ Name,Additional Attributes/ Additional Attribute/ Data Type,Additional Attributes/ Additional Attribute/ Description,Additional Attributes/ Additional Attribute/ Measurement Resolution,Additional Attributes/ Additional Attribute/ Parameter Range Begin,Additional Attributes/ Additional Attribute/ Parameter Range End,Additional Attributes/ Additional Attribute/ Parameter Units of Measure,Additional Attributes/ Additional Attribute/ Parameter Value Accuracy,Additional Attributes/ Additional Attribute/ Value Accuracy Explanation,Additional Attributes/ Additional Attribute/ Value,CSDT Description/ Primary CDST,CSDT Description/ Implementation,CSDT Description/ CSDT Comments,CSDT Description/ Indirect Reference,Collection Associations/ Collection Association/ Short Name,Collection Associations/ Collection Association/ Version Id,Collection Associations/ Collection Association/ Collection Type,Collection Associations/ Collection Association/ Collection Use,Campaigns/ Campaign/ Short Name *,Campaigns/ Campaign/ Long Name *,Campaigns/ Campaign/ Start Date,Campaigns/ Campaign/ End Date,TwoD Coordinate Systems/ TwoD Coordinate System/ TwoD Coordinate System Name,TwoD Coordinate Systems/ TwoD Coordinate System/ Coordinate 1/ Minimum Value,TwoD Coordinate Systems/ TwoD Coordinate System/ Coordinate 1/ Maximum Value,TwoD Coordinate Systems/ TwoD Coordinate System/ Coordinate 2/ Minimum Value,TwoD Coordinate Systems/ TwoD Coordinate System/ Coordinate 2/ Maximum Value,Online Access URLs/ Online Access URL/ URL,Online Access URLs/ Online Access URL/ URL Description,Online Access URLs/ Online Access URL/ Mime Type,Online Resources/ Online Resource/ URL,Online Resources/ Online Resource/ Description,Online Resources/ Online Resource/ Type,Online Resources/ Online Resource/ MimeType,Associated DIFs/ DIF/ Entry Id,Spatial/ Spatial Coverage Type,Spatial/ Horizontal Spatial Domain/ Zone Identifier,Spatial/ Horizontal Spatial Domain/ Geometry/ Coordinate System,Spatial/ Horizontal Spatial Domain/ Geometry/ Point/ Point Longitude,Spatial/ Horizontal Spatial Domain/ Geometry/ Point/ Point Latitude,Spatial/ Horizontal Spatial Domain/ Geometry/ Bounding Rectangle,Spatial/ Horizontal Spatial Domain/ Geometry/ Bounding Rectangle/ Center Point/ Point/ Point Longitude,Spatial/ Horizontal Spatial Domain/ Geometry/ Bounding Rectangle/ Center Point/ Point/ Point Latitude,Spatial/ Horizontal Spatial Domain/ Geometry/ GPolygon/ Boundary/ Point/ Point Longitude,Spatial/ Horizontal Spatial Domain/ Geometry/ GPolygon/ Boundary/ Point/ Point Latitude,Spatial/ Horizontal Spatial Domain/ Geometry/ GPolygon/ Exclusive Zone/ Boundary/ Point/ Point Longitude,Spatial/ Horizontal Spatial Domain/ Geometry/ GPolygon/ Exclusive Zone/ Boundary/ Point/ Point Latitude,Spatial/ Horizontal Spatial Domain/ Geometry/ GPolygon/ Center Point/ Point/ Point Longitude,Spatial/ Horizontal Spatial Domain/ Geometry/ GPolygon/ Center Point/ Point/ Point Latitude,Spatial/ Horizontal Spatial Domain/ Geometry/ Line/ Point/ Point Longitude *,Spatial/ Horizontal Spatial Domain/ Geometry/ Line/ Point/ Point Latitude *,Spatial/ Horizontal Spatial Domain/ Geometry/ Line/ Center Point/ Point/ Point Longitude,Spatial/ Horizontal Spatial Domain/ Geometry/ Line/ Center Point/ Point/ Point Latitude,Vertical Spatial Domain/ Type,Vertical Spatial Domain/ Value,Spatial/ Orbit Parameters/ Swath Width,Spatial/ Orbit Parameters/ Period,Spatial/ Orbit Parameters/ Inclination Angle,Spatial/ Orbit Parameters/ Number of Orbits,Spatial/ Orbit Parameters/ Start Circular Latitude,Spatial/ Granule Spatial Representation,Metadata Standard Name,Metadata Standard Version,Provider Browse Ids/ Provider Browse Id,Provider Browse URLs/ Provider Browse URL/ URL,Provider Browse URLs/ Provider Browse URL/ File Size,Provider Browse URLs/ Provider Browse URL/ Description,Provider Browse URLs/ Provider Browse URL/ Mime Type,Spatial Info/ Spatial Coverage Type,Spatial Info/ Vertical Coordinate System/ Altitude System Definition/ Datum Name,Spatial Info/ Vertical Coordinate System/ Altitude System Definition/ Distance Units,Spatial Info/ Vertical Coordinate System/ Altitude System Definition/ Encoding Method,Spatial Info/ Vertical Coordinate System/ Altitude System Definition/ Resolutions/ Resolution,Spatial Info/ Vertical Coordinate System/ Depth System Definition/ Datum Name,Spatial Info/ Vertical Coordinate System/ Depth System Definition/ Distance Units,Spatial Info/ Vertical Coordinate System/ Depth System Definition/ Encoding Method,Spatial Info/ Vertical Coordinate System/ Depth System Definition/ Resolutions/ Resolution,Spatial Info/ Horizontal Coordinate System/ Geodetic Model/ Horizontal Datum Name,Spatial Info/ Horizontal Coordinate System/ Geodetic Model/ Ellipsoid Name,Spatial Info/ Horizontal Coordinate System/ Geodetic Model/ Semi Major Axis,Spatial Info/ Horizontal Coordinate System/ Geodetic Model/ Denominator of Flattening Ratio,Spatial Info/ Horizontal Coordinate System/ Geographic Coordinate System/ Geographic Coordinate Units,Spatial Info/ Horizontal Coordinate System/ Geographic Coordinate System/ Latitude Resolution,Spatial Info/ Horizontal Coordinate System/ Geographic Coordinate System/ Longitude Resolution,Spatial Info/ Horizontal Coordinate System/ Planar Coordinate Systems/ Planar Coordinate System/ Planar Coordinate System Id,Spatial Info/ Horizontal Coordinate System/ Planar Coordinate Systems/ Planar Coordinate System/ Planar Coordinate Information/ Distance Units,Spatial Info/ Horizontal Coordinate System/ Planar Coordinate Systems/ Planar Coordinate System/ Planar Coordinate Information/ Encoding Method,Spatial Info/ Horizontal Coordinate System/ Planar Coordinate Systems/ Planar Coordinate System/ Planar Coordinate Information/ Distance and Bearing Representation/ Distance Resolution,Spatial Info/ Horizontal Coordinate System/ Planar Coordinate Systems/ Planar Coordinate System/ Planar Coordinate Information/ Distance and Bearing Representation/ Bearing Resolution,Spatial Info/ Horizontal Coordinate System/ Planar Coordinate Systems/ Planar Coordinate System/ Planar Coordinate Information/ Distance and Bearing Representation/ Bearing Units,Spatial Info/ Horizontal Coordinate System/ Planar Coordinate Systems/ Planar Coordinate System/ Planar Coordinate Information/ Distance and Bearing Representation/ Bearing Reference Direction,Spatial Info/ Horizontal Coordinate System/ Planar Coordinate Systems/ Planar Coordinate System/ Planar Coordinate Information/ Distance and Bearing Representation/ Bearing Reference Meridian,Spatial Info/ Horizontal Coordinate System/ Planar Coordinate Systems/ Planar Coordinate System/ Planar Coordinate Information/ Coordinate Representation/ Abscissa Resolution,Spatial Info/ Horizontal Coordinate System/ Planar Coordinate Systems/ Planar Coordinate System/ Planar Coordinate Information/ Coordinate Representation/ Ordinate Resolution,Spatial Info/ Horizontal Coordinate System/ Planar Coordinate System/ Map Projection/ Map Projection Name,Spatial Info/ Horizontal Coordinate System/ Planar Coordinate System/ Map Projection/ Map Projection Pointer,Spatial Info/ Horizontal Coordinate System/ Planar Coordinate System/ Local Planar Coordinate System/ Description,Spatial Info/ Horizontal Coordinate System/ Planar Coordinate System/ Local Planar Coordinate System/ Geo Reference Information,Spatial Info/ Horizontal Coordinate System/ Planar Coordinate System/ Grid Coordinate System Name,Spatial Info/ Horizontal Coordinate System/ Local Coordinate System/ Description,Spatial Info/ Horizontal Coordinate System/ Local Coordinate System/ Geo Reference Information,Checked by:,Comments:"

granule_output_header = 'ECHO10 Granule Elements,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Platforms/ Platform,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n\
* = GCMD controlled: http://gcmd.nasa.gov/learn/keyword_list.html,,,,,,,,,,,,,,,,,,,,,,Spatial,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Platforms/ Platform/ Instruments/ Instrument,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n\
,,,,,,,,,,,,,,,,,,,Temporal  (Must have field marked (a) OR fields marked (b)),,,,,,"Spatial/ Horizontal Spatial Domain (must include option (1), (2), (3), or (4))",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Measured Parameters/ Measured Parameter,,,,,,,,,,,,,,,Platforms/ Platform/ Instruments/ Instrument/ Sensors/ Sensor,,,,,,,,,,,,,,,,,,,,,,,,,Associated Browse Image,,,,,,\n\
,,,,,Collection (Must have fields marked (a) OR field marked (b)),,,,,Data Granule,,,,,,,PGE Version Class,,,Temporal/ Range Date Time,,,Spatial/ Vertical Spatial Domains/ Vertical Spatial Domain,,,Spatial/ Horizontal Spatial Domain/ Geometry/ Point,,Spatial/ Horizontal Spatial Domain/ Geometry/ Bounding Rectangle (2),,,,,,Spatial/ Horizontal Spatial Domain/ Geometry/ GPolygon (3),,,,,,Spatial/ Horizontal Spatial Domain/ Geometry/ Line (4),,,,Spatial/ Horizontal Spatial Domain/ Orbit,,,,,,,Orbit Calculated Spatial Domains/ Orbit Calculated Spatial Domain,,,,,,,Measured Parameters/ Measured Parameter/ QA Stats,,,,Measured Parameters/ Measured Parameter/ QA Flags,,,,,,,,Platforms/ Platform/ Instruments/ Instrument/ Characteristics/ Characteristic,,,Platforms/ Platform/ Instruments/ Instrument/ Sensors/ Sensor/ Characteristics/ Characteristic,,,,Additional Attributes/ Additional Attribute,,,TwoD Coordinate Systems/ TwoD Coordinate System,,,,,,Online Access URLs/ Online Access URL,,,Online Resources/ Online Resource,,,,,,,,,Provider Browse URL,,,,,\n\
Collection Name (Concept Id) - Granule UR,Granule UR,Insert Time,Last Update,Delete Time,(a) Collection/ Short Name,(a) Collection/ Version Id,(b) Collection/ Data Set Id,Restriction Flag,Restriction Comment,Data Granule/ Size MB Data Granule,Data Granule/ Reprocessing Planned,Data Granule/ Reprocessing Actual,Data Granule/ Producer Granule Id,Data Granule/ Day Night Flag,Data Granule/ Production Date Time,Data Granule/ Local Version Id,PGE Version Class/ PGE Name,PGE Version Class/ PGE Version, (a) Temporal/ Single Date Time,(b) Temporal/ Range Date Time/ Beginning Date Time,(b) Temporal/ Range Date Time/ Ending Date Time,Spatial/ Granule Locality/ Locality Value,Spatial/ Vertical Spatial Domains/ Vertical Spatial Domain/ Type,Spatial/ Vertical Spatial Domains/ Vertical Spatial Domain/ Value,Spatial/ Horizontal Spatial Domain/ Zone Identifier,Spatial/ Horizontal Spatial Domain/ Geometry/ Point/ Point Longitude,Spatial/ Horizontal Spatial Domain/ Geometry/ Point/ Point Latitude,Spatial/ Horizontal Spatial Domain/ Geometry/ Bounding Rectangle/ West Bounding Coordinate,Spatial/ Horizontal Spatial Domain/ Geometry/ Bounding Rectangle/ North Bounding Coordinate,Spatial/ Horizontal Spatial Domain/ Geometry/ Bounding Rectangle/ East Bounding Coordinate,Spatial/ Horizontal Spatial Domain/ Geometry/ Bounding Rectangle/ South Bounding Coordinate,Spatial/ Horizontal Spatial Domain/ Geometry/ Bounding Rectangle/ Center Point/ Point Longitude,Spatial/ Horizontal Spatial Domain/ Geometry/ Bounding Rectangle/ Center Point/ Point Latitude,Spatial/ Horizontal Spatial Domain/ Geometry/ GPolygon/ Boundary/ Point/ Point Longitude,Spatial/ Horizontal Spatial Domain/ Geometry/ GPolygon/ Boundary/ Point/ Point Latitude,Spatial/ Horizontal Spatial Domain/ Geometry/ GPolygon/ Exclusive Zone/ Boundary/ Point/ Point Longitude,Spatial/ Horizontal Spatial Domain/ Geometry/ GPolygon/ Exclusive Zone/ Boundary/ Point/ Point Latitude,Spatial/ Horizontal Spatial Domain/ Geometry/ GPolygon/ Center Point/ Point/ Point Longitude,Spatial/ Horizontal Spatial Domain/ Geometry/ GPolygon/ Center Point/ Point/ Point Latitude,Spatial/ Horizontal Spatial Domain/ Geometry/ Line/ Point/ Point Longitude,Spatial/ Horizontal Spatial Domain/ Geometry/ Line/ Point/ Point Latitude,Spatial/ Horizontal Spatial Domain/ Geometry/ Line/ Center Point/ Point/ Point Longitude,Spatial/ Horizontal Spatial Domain/ Geometry/ Line/ Center Point/ Point/ Point Latitude,Spatial/ Horizontal Spatial Domain/ Orbit/ Ascending Crossing,Spatial/ Horizontal Spatial Domain/ Orbit/ Start Lat,Spatial/ Horizontal Spatial Domain/ Orbit/ Start Direction,Spatial/ Horizontal Spatial Domain/ Orbit/ End Lat,Spatial/ Horizontal Spatial Domain/ Orbit/ End Direction,Spatial/ Horizontal Spatial Domain/ Orbit/ Center Point/ Point Longitude,Spatial/ Horizontal Spatial Domain/ Orbit/ Center Point/ Point Latitude,Orbit Calculated Spatial Domains/ Orbit Calculated Spatial Domain/ Orbital Model Name,Orbit Calculated Spatial Domains/ Orbit Calculated Spatial Domain/ Orbit Number,Orbit Calculated Spatial Domains/ Orbit Calculated Spatial Domain/ Start Orbit Number,Orbit Calculated Spatial Domains/ Orbit Calculated Spatial Domain/ Stop Orbit Number,Orbit Calculated Spatial Domains/ Orbit Calculated Spatial Domain/ Equator Crossing Longitude,Orbit Calculated Spatial Domains/ Orbit Calculated Spatial Domain/ Equator Crossing Date Time,Measured Parameters/ Measured Parameter/ Parameter Name,Measured Parameters/ Measured Parameter/ QA Stats/ QA Percent Missing Data,Measured Parameters/ Measured Parameter/ QA Stats/ QA Percent Out of Bounds Data,Measured Parameters/ Measured Parameter/ QA Stats/ QA Percent Interpolated Data,Measured Parameters/ Measured Parameter/ QA Stats/ QA Percent Cloud Cover,Measured Parameters/ Measured Parameter/ QA Flags/ Automatic Quality Flag,Measured Parameters/ Measured Parameter/ QA Flags/ Automatic Quality Flag Explanation,Measured Parameters/ Measured Parameter/ QA Flags/ Operational Quality Flag,Measured Parameters/ Measured Parameter/ QA Flags/ Operational Quality Flag Explanation,Measured Parameters/ Measured Parameter/ QA Flags/ Science Quality Flag,Measured Parameters/ Measured Parameter/ QA Flags/ Science Quality Flag Explanation,Platforms/ Platform/ Short Name *,Platforms/ Platform/ Instruments/ Instrument/ Short Name *,Platforms/ Platform/ Instruments/ Instrument/ Characteristics/ Name,Platforms/ Platform/ Instruments/ Instrument/ Characteristics/ Value,Platforms/ Platform/ Instruments/ Instrument/ Sensors/ Sensor/ Short Name,Platforms/ Platform/ Instruments/ Instrument/ Sensors/ Sensor/ Characteristics/ Characteristic/ Name,Platforms/ Platform/ Instruments/ Instrument/ Sensors/ Sensor/ Characteristics/ Characteristic Value,Platforms/ Platform/ Instruments/ Instrument/ Operation Modes/ Operation Mode,Campaigns/ Campaign/ Short Name *,Additional Attributes/ Additional Attribute/ Name,Additional Attributes/ Additional Attribute/ Values/ Value,Input Granules/ Input Granule,TwoD Coordinate Systems/ TwoD Coordinate System/ Start Coordinate 1,TwoD Coordinate Systems/ TwoD Coordinate System/ End Coordinate 1,TwoD Coordinate Systems/ TwoD Coordinate System/ Start Coordinate 2,TwoD Coordinate Systems/ TwoD Coordinate System/ End Coordinate 2,TwoD Coordinate Systems/ TwoD Coordinate System/ TwoD Coordinate System Name,Price,Online Access URLs/ Online Access URL/ URL,Online Access URLs/ Online Access URL/ URL Description,Online Access URLs/ Online Access URL/ Mime Type,Online Resources/ Online Resource/ URL,Online Resources/ Online Resource/ Description,Online Resources/ Online Resource/ Type,Online Resources/ Online Resource/ Mime Type,Orderable,Data Format,Visible,Cloud Cover,Provider Browse Ids/ Provider Browse Id,Associated Browse Image URLs/ Provider Browse URL/ URL*,Associated Browse Image URLs/ Provider Browse URL/ File Size,Associated Browse Image URLs/ Provider Browse URL/ Description,Associated Browse Image URLs/ Provider Browse URL/ Mime Type,Checked By:,Comments:\n'

def silentremove(filename):
    try:
        os.remove(filename)
    except OSError as e: # this would be "except OSError, e:" before Python 2.6
        if e.errno != errno.ENOENT: # errno.ENOENT = no such file or directory
            raise # re-raise exception if a different error occured

def doCollectionCheckwithRecords(filename, outputform = 'CSV', outfilename = "result.csv"):
    xml = ElementTree.parse(filename)
    root_element = xml.getroot()
    ck = CollectionChecker.Checker()

    result = None
    for collection in root_element.iter('Collection'):
        metadata = XmlDictConfig(collection)
        # print "ShortName = " + metadata['ShortName']
        result = ck.checkAllJSON(metadata)

    if(outputform == 'JSON'):
        return result
    else:
        od = toOrderedDict(result)

        with open(outfilename, 'wb') as f:  # Just use 'w' mode in 3.x
            w = csv.DictWriter(f, od)
            w.writeheader()
            w.writerow(od)

        # for collection in root_element.iter('Collection'):
        #     metadata = XmlDictConfig(collection)
        #     # print "ShortName = " + metadata['ShortName']
        #     result = ck.checkAll(metadata)
        #     out_fp = open(outfilename, 'w')
        #     out_fp.write(collection_output_header)
        #     out_fp.write(metadata['ShortName']+ ', ' + result + '\n')
        #     out_fp.close()


def toOrderedDict(result):
    od = OrderedDict()
    # try match csv headers to result dict keys
    gist = {re.sub(r"\W", "", k): v for k, v in result.items()}
    for col in collection_output_header.split(','):
        k = re.sub(r"\W", "", col)
        if k in gist:
            # print "matched", col, k
            od[col] = gist[k]
        else:
            # print "missing:", col, k
            od[col] = ""
    # print od
    return od


def doCollectionCheckwithShortNameList(filename, outfilename = "result.csv", tmp_path = "./"):
    in_fp = open(filename, 'r')
    # out_fp = open(outfilename, 'w')
    out_fp = open(outfilename, "wb")
    header_written = False
    w = None
    ck = CollectionChecker.Checker()


    for line in iter(in_fp.readline, b''):
        shortName = line.rstrip()
        if len(shortName) != 0: 
            result = searchCollection(limit=100, short_name=shortName)
            result[0].download(tmp_path);
            xml = ElementTree.parse(tmp_path+shortName.replace('/', ''))
            root_element = xml.getroot()
            for collection in root_element.iter('Collection'):
                metadata = XmlDictConfig(collection)
                # print "ShortName = " + metadata['ShortName']
                result = ck.checkAll(metadata)
                od = toOrderedDict(result)
                if not header_written:
                    w = csv.DictWriter(out_fp, od)
                    w.writeheader()
                    header_written = True
                # while result.find(", ,") != -1:
                #     pos = result.find(", ,")
                #     result = result[:(pos+1)] + "np" + result[(pos+1):]
                # result += ",np,np,np,np,np,np"
                # out_fp.write(metadata['ShortName']+ ", " + ck.checkAll(metadata) + '\n')
                # out_fp.write(metadata['ShortName']+ ", " + result + '\n')
                w.writerow(od)
            silentremove(tmp_path+shortName.replace('/', ''))
    in_fp.close()
    out_fp.close()


def doGranuleCheckwithRecords(filename, outputform = 'CSV', outfilename = "result.csv"):
    xml = ElementTree.parse(filename)
    root_element = xml.getroot()
    ck = GranuleChecker.Checker()

    if(outputform == 'JSON'):
        for granule in root_element.iter('Granule'):
            metadata = XmlDictConfig(granule)
            return ck.checkAllJSON(metadata)
    else:
        out_fp = open(outfilename, 'w')
        out_fp.write(granule_output_header)
        for granule in root_element.iter('Granule'):
            metadata = XmlDictConfig(granule)
            res = ck.checkAll(metadata)
        out_fp.write(filename + ', ' + res + '\n')
        out_fp.close()



def doGranuleCheckwithIDList(filename, outfilename = "result.csv", tmp_path = "./"):
    in_fp = open(filename, 'r')
    out_fp = open(outfilename, 'w')
    out_fp.write(granule_output_header)
    ck = GranuleChecker.Checker()

    for line in iter(in_fp.readline, b''):
        conceptID = line.rstrip()
        if len(conceptID) != 0: 
            result = searchGranule(limit=100, concept_id=conceptID)
            result[0].download(tmp_path);
            xml = ElementTree.parse(tmp_path+conceptID)
            root_element = xml.getroot()
            for granule in root_element.iter('Granule'):
                metadata = XmlDictConfig(granule)
                out_fp.write(conceptID + ", " + ck.checkAll(metadata) + '\n')
            silentremove(tmp_path + conceptID)
    in_fp.close()
    out_fp.close()






