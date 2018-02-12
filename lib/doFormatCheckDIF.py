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

#import sys
import os, errno
import json
import CollectionCheckerDIF
#import GranuleChecker
from cmr import searchCollection
#from cmr import searchGranule
from xml.etree import ElementTree
from xmlParser import XmlDictConfigDIF
from xmlParser import XmlDictConfig

collection_output_header = 'DIF10 Collection Elements,\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,,,,,,,,,,,,,,,,,\n\
"* = GCMD controlled: http://gcmd.nasa.gov/learn/keyword_list.html\nThese datasets were reviewed in comparison to GCMD Keyword Version: 8.4.1",\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,,,,,,,,,,,,,,,,,\n\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,,,,,,,,,,,,,Platform\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,,,,,,,,,,,,,Spatial_Coverage\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,Organization\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,,,,,,,,,,,,,,,\n\
,,,,,,,,,,,,,,,,,,,,,,Personnel\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,Platform/ Instrument\
,,,,,,,,,,,,,,Platform/ Instrument/ Sensor\
,,,,,,,,,,,,"Temporal_Coverage (Must include a choice of 1, 2, 3 or 4)"\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"Spatial_Coverage/ Geometry (must have a choice of (1), (2), (3) or (4))"\
,,,,,,,,,,,Spatial_Coverage/ Spatial_Info\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,,Organization/ Personnel\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\
,,,,,,,,,,\n\
,,,,,Dataset_Citation,,,,,,,,,,,,,,,Personnel/ Contact_Person,,,,,,,,,,,Personnel/ Contact_Group,,,,,,,,,Science_Keywords,,,,,,,,,,,,Platform/ Characteristics,,,,,,,,,Platform/ Instrument/ Characteristics,,,,,,,,\
Platform/ Instrument/ Sensor/ Characteristics,,,,,,,,,,,Temporal_Coverage/ Range_DateTime (1),,,Temporal_Coverage/ Periodic_DateTime (3),,,,,,,Temporal_Coverage/ Paleo_DateTime (4),,,,,,,,,,,,,,Spatial_Coverage/ Geometry/ Bounding_Rectangle (1),,,,,,,,,,Spatial_Coverage/ Geometry/ Point (2),,Spatial_Coverage/ Geometry/ Line (3),,,,Spatial_Coverage/ Geometry/ Polygon (4),,,,Spatial_Coverage/ Orbit_Parameters,,,,,Spatial_Coverage/ Vertical_Spatial_Info,,,Spatial_Coverage/ Spatial_Info/ Horizontal_Coordinate_System/ Geodetic_Model,,,,Spatial_Coverage/ Spatial_Info/ Horizontal_Coordinate_System/ Geographic_Coordinate_System,,,Spatial_Coverage/ Spatial_Info/ Horizontal_Coordinate_System/ Local_Coordinate_System,,Spatial_Coverage/ Spatial_Info/ TwoD_Coordinate_System,,,,,Location,,,,,,Data_Resolution,,,,,,,Project,,,,,,,,,,,,,,,,,,Organization/ Personnel/ Contact_Person  ,,,,,,,,,,,Organization/ Personnel/ Contact_Group,,,,,,,,,Distribution  ,,,,Multimedia_Sample,,,,,Reference,,,,,,,,,,,,,,,,,Summary  ,,Related_URL  ,,,,,,,Metadata_Association,,,,Additional_Attributes,,,,,,,,,,,,,,,,,Metadata_Dates,,,,,,,,,Extended_Metadata,,,,,,,,,,,,,,,\n\
Dataset Id (short name) - umm-json link,Entry_ID/ Short_Name,Entry_ID/ Version,Version_Description,Entry_Title,Dataset_Citation/ Dataset_Creator,Dataset_Citation/ Dataset_Editor,Dataset_Citation/ Dataset_Title,Dataset_Citation/ Dataset_Series_Name,Dataset_Citation/ Dataset_Release_Date,Dataset_Citation/ Dataset_Release_Place,Dataset_Citation/ Dataset_Publisher,Dataset_Citation/ Version,Dataset_Citation/ Issue_Identification,Dataset_Citation/ Data_Presentation_Form,Dataset_Citation/ Other_Citation_Details,* where type must = \"DOI\" Dataset_Citation/ Persistent_Identifier/ Type,* DOI should be entered here Dataset_Citation/ Persistent_Identifier/ Identifier,Dataset_Citation/ Online_Resource,Personnel/ Role ,Personnel/ Contact_Person/ First_Name,Personnel/ Contact_Person/ Middle_Name,Personnel/ Contact_Person/ Last_Name,Personnel/ Contact_Person/ Address/ Street_Address,Personnel/ Contact_Person/ Address/ City,Personnel/ Contact_Person/ Address/ State_Province,Personnel/ Contact_Person/ Address/ Postal_Code,Personnel/ Contact_Person/ Address/ Country,Personnel/ Contact_Person/ Email,Personnel/ Contact_Person/ Phone/ Number,Personnel/ Contact_Person/ Phone/ Type ,Personnel/ Contact_Group/ Name,Personnel/ Contact_Group/ Address/ Street_Address,Personnel/ Contact_Group/ Address/ City,Personnel/ Contact_Group/ Address/ State_Province,Personnel/ Contact_Group/ Address/ Postal_Code,Personnel/ Contact_Group/ Address/ Country,Personnel/ Contact_Group/ Email,Personnel/ Contact_Group/ Phone/ Number,Personnel/ Contact_Group/ Phone/ Type,Science_Keywords/ Category *,Science_Keywords/ Topic *,Science_Keywords/ Term *,Science_Keywords/ Variable_Level_1 *,Science_Keywords/ Variable_Level_1/ Variable_Level_2 *,Science_Keywords/ Variable_Level_1/ Variable_Level_2/ Variable_Level_3 *,Science_Keywords/ Variable_Level_1/ Variable_Level_2/ Variable_Level_3/ Detailed_Variable,ISO_Topic_Category,Ancillary_Keyword,Platform/ Type *,Platform/ Short_Name *,Platform/ Long_Name*,Platform/ Characteristics/ Name ,Platform/ Characteristics/ Description,Platform/ Characteristics/ DataType,Platform/ Characteristics/ Unit,Platform/ Characteristics/ Value,Platform/ Instrument/ Short_Name *,Platform/ Instrument/ Long_Name *,Platform/ Instrument/ Technique,Platform/ Instrument/ NumberOfSensors,Platform/ Instrument/ Characteristics/ Name,Platform/ Instrument/ Characteristics/ Description,Platform/ Instrument/ Characteristics/ DataType,Platform/ Instrument/ Characteristics/ Unit ,Platform/ Instrument/ Characteristics/ Value,Platform/ Instrument/ OperationalMode,Platform/ Instrument/ Sensor/ Short_Name *,Platform/ Instrument/ Sensor/ Long_Name *,Platform/ Instrument/ Sensor/ Technique,Platform/ Instrument/ Sensor/ Characteristics/ Name ,Platform/ Instrument/ Sensor/ Characteristics/ Description ,Platform/ Instrument/ Sensor/ Characteristics/ DataType ,Platform/ Instrument/ Sensor/ Characteristics/ Unit ,Platform/ Instrument/ Sensor/ Characteristics/ Value ,Temporal_Coverage/ Time_Type,Temporal_Coverage/ Date_Type,Temporal_Coverage/ Temporal_Range_Type,Temporal_Coverage/ Precision_Of_Seconds,Temporal_Coverage/ Ends_At_Present_Flag,Temporal_Coverage/ Range_DateTime/ Beginning_Date_Time ,Temporal_Coverage/ Range_DateTime/ Ending_Date_Time ,Temporal_Coverage/ Single_Date_Time (2),Temporal_Coverage/ Periodic_DateTime/ Name,Temporal_Coverage/ Periodic_DateTime/ Start_Date,Temporal_Coverage/ Periodic_DateTime/ End_Date,Temporal_Coverage/ Periodic_DateTime/ Duration_Unit,Temporal_Coverage/ Periodic_DateTime/ Duration_Value,Temporal_Coverage/ Periodic_DateTime/ Period_Cycle_Duration_Unit,Temporal_Coverage/ Periodic_DateTime/ Period_Cycle_Duration_Value,Temporal_Coverage/ Paleo_DateTime/ Paleo_Start_Date,Temporal_Coverage/ Paleo_DateTime/ Paleo_Stop_Date,Temporal_Coverage/ Paleo_DateTime/ Chronostratigraphic_Unit/ Eon,Temporal_Coverage/ Paleo_DateTime/ Chronostratigraphic_Unit/ Era,Temporal_Coverage/ Paleo_DateTime/ Chronostratigraphic_Unit/ Period,Temporal_Coverage/ Paleo_DateTime/ Chronostratigraphic_Unit/ Epoch,Temporal_Coverage/ Paleo_DateTime/ Chronostratigraphic_Unit/ Stage,Temporal_Coverage/ Paleo_DateTime/ Chronostratigraphic_Unit/ Detailed_Classification ,Temporal_Coverage/ Temporal_Info/ Ancillary_Temporal_Keyword ,DataSet_Progress,Spatial_Coverage/ Spatial_Coverage_Type,Spatial_Coverage/ Granule_Spatial_Representation,Spatial_Coverage/ Zone_Identifier,Spatial_Coverage/ Geometry/ Coordinate_System ,Spatial_Coverage/ Geometry/ Bounding_Rectangle/ Southernmost_Latitude,Spatial_Coverage/ Geometry/ Bounding_Rectangle/ Northernmost_Latitude,Spatial_Coverage/ Geometry/ Bounding_Rectangle/ Westernmost_Longitude,Spatial_Coverage/ Geometry/ Bounding_Rectangle/ Easternmost_Longitude,Spatial_Coverage/ Geometry/ Bounding_Rectangle/ Minimum_Altitude,Spatial_Coverage/ Geometry/ Bounding_Rectangle/ Maximum_Altitude,Spatial_Coverage/ Geometry/ Bounding_Rectangle/ Altitude_Unit,Spatial_Coverage/ Geometry/ Bounding_Rectangle/ Minimum_Depth,Spatial_Coverage/ Geometry/ Bounding_Rectangle/ Maximum_Depth,Spatial_Coverage/ Geometry/ Bounding_Rectangle/ Depth_Unit,Spatial_Coverage/ Geometry/ Point/ Point_Longitude,Spatial_Coverage/ Geometry/ Point/ Point_Latitude,Spatial_Coverage/ Geometry/ Line/ Point/ Point_Longitude,Spatial_Coverage/ Geometry/ Line/ Point/ Point_Latitude,Spatial_Coverage/ Geometry/ Line/ Center_Point/ Point_Latitude,Spatial_Coverage/ Geometry/ Line/ Center_Point/ Point_Latitude,Spatial_Coverage/ Geometry/ Polygon/ Boundary/ Point/ Point_Longitude,Spatial_Coverage/ Geometry/ Polygon/ Boundary/ Point/ Point_Latitude,Spatial_Coverage/ Geometry/ Polygon/ Exclusion_Zone/ Boundary/ Point/ Point_Longitude,Spatial_Coverage/ Geometry/ Polygon/ Exclusion_Zone/ Boundary/ Point/ Point_Latitude,Spatial_Coverage/ Orbit_Parameters/ Swath_Width,Spatial_Coverage/ Orbit_Parameters/ Period,Spatial_Coverage/ Orbit_Parameters/ Inclination_Angle,Spatial_Coverage/ Orbit_Parameters/ Number_of_Orbits,Spatial_Coverage/ Orbit_Parameters/ Start_Circular_Latitude,Spatial_Coverage/ Vertical_Spatial_Info/ Type,Spatial_Coverage/ Vertical_Spatial_Info/ Value,Spatial_Coverage/ Spatial_Info/ Spatial_Coverage_Type,Spatial_Coverage/ Spatial_Info/ Horizontal_Coordinate_System/ Geodetic_Model/ Horizontal_DatumName,Spatial_Coverage/ Spatial_Info/ Horizontal_Coordinate_System/ Geodetic_Model/ Ellipsoid_Name,Spatial_Coverage/ Spatial_Info/ Horizontal_Coordinate_System/ Geodetic_Model/ Semi_Major_Axis,Spatial_Coverage/ Spatial_Info/ Horizontal_Coordinate_System/ Geodetic_Model/ Denominator_Of_Flattening_Ratio,Spatial_Coverage/ Spatial_Info/ Horizontal_Coordinate_System/ Geographic_Coordinate_System/ GeographicCoordinateUnits,Spatial_Coverage/ Spatial_Info/ Horizontal_Coordinate_System/ Geographic_Coordinate_System/ LatitudeResolution,Spatial_Coverage/ Spatial_Info/ Horizontal_Coordinate_System/ Geographic_Coordinate_System/ LongitudeResolution,Spatial_Coverage/ Spatial_Info/ Horizontal_Coordinate_System/ Local_Coordinate_System/ Description,Spatial_Coverage/ Spatial_Info/ Horizontal_Coordinate_System/ Local_Coordinate_System/ GeoReferenceInformation,Spatial_Coverage/ Spatial_Info/ TwoD_Coordinate_System/ TwoD_Coordinate_System_Name,Spatial_Coverage/ Spatial_Info/ TwoD_Coordinate_System/ Coordinate1/ Minimum_Value ,Spatial_Coverage/ Spatial_Info/ TwoD_Coordinate_System/ Coordinate1/ Maximum_Value,Spatial_Coverage/ Spatial_Info/ TwoD_Coordinate_System/ Coordinate2/ Minimum_Value,Spatial_Coverage/ Spatial_Info/ TwoD_Coordinate_System/ Coordinate2/ Maximum_Value,Location/ Location_Category *,Location/ Location_Type *,Location/ Location_Subregion1 *,Location/ Location_Subregion2 *,Location/ Location_Subregion3 *,Location/ Detailed_Location,Data_Resolution/ Latitude_Resolution,Data_Resolution/ Longitude_Resolution,Data_Resolution/ Horizontal_Resolution_Range,Data_Resolution/ Vertical_Resolution,Data_Resolution/ Vertical_Resolution_Range,Data_Resolution/ Temporal_Resolution,Data_Resolution/ Temporal_Resolution_Range,Project/ Short_Name *,Project/ Long_Name *,Project/ Campaign,Project/ Start_Date,Project/ End_Date,Quality,Access_Constraints,Use_Constraints,DataSet_Language,Originating_Center,Organization/ Organization_Type,Organization/ Organization_Name/ Short_Name *,Organization/ Organization_Name/ Long_Name *,Organization/ Hours_Of_Service,Organization/Instructions,Organization/Organization_URL,Organization/Data_Set_ID,Organization/ Personnel/ Role ,Organization/ Personnel/ Contact_Person/ First_Name,Organization/ Personnel/ Contact_Person/ Middle_Name,Organization/ Personnel/ Contact_Person/ Last_Name,Organization/ Personnel/ Contact_Person/ Address/ Street_Address,Organization/ Personnel/ Contact_Person/ Address/ City,Organization/ Personnel/ Contact_Person/ Address/ State_Province,Organization/ Personnel/ Contact_Person/ Address/ Postal_Code,Organization/ Personnel/ Contact_Person/ Address/ Country,Organization/ Personnel/ Contact_Person/ Email,Organization/ Personnel/ Contact_Person/ Phone/ Number,Organization/ Personnel/ Contact_Person/ Phone/ Type ,Organization/ Personnel/ Contact_Group/ Name,Organization/ Personnel/ Contact_Group/ Address/ Street_Address,Organization/ Personnel/ Contact_Group/ Address/ City,Organization/ Personnel/ Contact_Group/ Address/ State_Province,Organization/ Personnel/ Contact_Group/ Address/ Postal_Code,Organization/ Personnel/ Contact_Group/ Address/ Country,Organization/ Personnel/ Contact_Group/ Email,Organization/ Personnel/ Contact_Group/ Phone/ Number,Organization/ Personnel/ Contact_Group/ Phone/ Type,Distribution/ Distribution_Media,Distribution/ Distribution_Size,Distribution/ Distribution_Format,Distribution/ Fees,Multimedia_Sample/ File,Multimedia_Sample/ URL,Multimedia_Sample/Format,Multimedia_Sample/Caption,Multimedia_Sample/Description,Reference/ Citation,Reference/ Author,Reference/ Publication Date,Reference/ Title,Reference/ Series,Reference/ Edition,Reference/ Volume,Reference/ Issue,Reference/\
Report_Number,Reference/Publication_Place,Reference/ Publisher,Reference/ Pages,Reference/ ISBN,Reference/Persistent_Identifier/ Type,Reference/Persistent_Identifier/ Identifier,Reference/Online_Resource,Reference/Other_Reference_Details,Summary/ Abstract,Summary/ Purpose,Related_URL/ URL_Content_Type/ Type *,Related_URL/ URL_Content_Type/ Subtype *,Related_URL/ Protocol,Related_URL/ URL,Related_URL/ Title,Related_URL/ Description,Related_URL/ Mime_Type,Metadata_Association/ Entry_Id,Metadata_Association/ Type,Metadata_Association/ Description,IDN_Node/ Short_Name,Additional_Attributes/ Name,Additional_Attributes/ DataType,Additional_Attributes/ Description,Additional_Attributes/ MeasurementResolution,Additional_Attributes/ ParameterRangeBegin,Additional_Attributes/ ParameterRangeEnd,Additional_Attributes/ ParameterUnitsOfMeasure,Additional_Attributes/ ParameterValueAccuracy,Additional_Attributes/ ValueAccuracyExplanation,Additional_Attributes/ Value,Product_Level_ID,Product_Flag,Collection_Data_Type,Originating_Metadata_Node,Metadata_Name,Metadata_Version,DIF_Revision_History,Metadata_Dates/ Metadata_Creation,Metadata_Dates/ Metadata_Last_Revision,Metadata_Dates/ Metadata_Future_Review,Metadata_Dates/ Metadata_Delete,Metadata_Dates/ Data_Creation,Metadata_Dates/ Data_Last_Revision,Metadata_Dates/ Data_Future_Review,Metadata_Dates/ Data_Delete,Private,Extended_Metadata/ Metadata/ Group,Extended_Metadata/ Metadata/ Name,Extended_Metadata/ Metadata/ Description,Extended_Metadata/ Metadata/ Type,Extended_Metadata/ Metadata/ Update_Date,Extended_Metadata/ Value,Checked by:,Comments:,# Red fields (absolute errors):,# Yellow fields (recommended fixes),# Green fields (observations/ may or may not need to be fixed),# np fields (not in the metadata, and not marked by any color),# fields checked (265 - #np fields),% red fields,% yellow fields,% green fields\n'


def silentremove(filename):
    try:
        os.remove(filename)
    except OSError as e: # this would be "except OSError, e:" before Python 2.6
        if e.errno != errno.ENOENT: # errno.ENOENT = no such file or directory
            raise # re-raise exception if a different error occured

def replace_file(filename):
    f = open(filename)
    lines = f.readlines()
    f.close()

    length = len(lines)

    for i in range(length):
        if(lines[i][0:4] == "<DIF"):
            #print lines[i]
            lines[i] = '<DIF>\n'
    f = open(filename, 'w')
    for l in lines:
        f.write(l)
    f.close()

def doCollectionCheckwithRecordsDIF(filename, outputform = 'CSV', outfilename = "result.csv"):
    replace_file(filename)

    xml = ElementTree.parse(filename)
    root_element = xml.getroot()
    ck = CollectionCheckerDIF.Checker()

    if (outputform == 'JSON'):
        for collection in root_element.iter('DIF'):
            metadata = XmlDictConfigDIF(collection)
            return ck.checkAllJSON(metadata)

    else:
        out_fp = open(outfilename, 'w')
        out_fp.write(collection_output_header)

        for collection in root_element.iter('DIF'):
            metadata = XmlDictConfigDIF(collection)
            result = ck.checkAll(metadata)

            out_fp.write(filename+ ", " +result + "\n")
        out_fp.close()




def doCollectionCheckwithShortNameListDIF(filename, outfilename = "result.csv", tmp_path = "./"):
    in_fp = open(filename, 'r')
    out_fp = open(outfilename, 'w')
    out_fp.write(collection_output_header)
    ck = CollectionCheckerDIF.Checker()

    for line in iter(in_fp.readline, b''):
        shortName = line.rstrip()
        if len(shortName) != 0:
            #print shortName
            result = searchCollection(limit=100, short_name=shortName)
            result[0].download(tmp_path);
            fileNameTemp = tmp_path+shortName.replace('/', '')
            replace_file(fileNameTemp)
            xml = ElementTree.parse(fileNameTemp)
            root_element = xml.getroot()
            for collection in root_element.iter('DIF'):
                metadata = XmlDictConfigDIF(collection)

                result = ck.checkAll(metadata)
                out_fp.write(shortName+ ", " + result + '\n')
            silentremove(tmp_path+shortName.replace('/', ''))
    in_fp.close()
    out_fp.close()





