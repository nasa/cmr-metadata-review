import datetime
import re
import urllib2
import requests

from parse.parseInstrument import parseInstrument
from parse.parsePlatform import parsePlatform
from parse.parseProjects import parseProjects
from parse.parseRuncontenttype import parseRuncontenttype
from parse.parseScienceKeyWord import parseScienceKeyWord
from parse.parseProvider import parseProvider
from parse.parseLocations import parseLocations
from parse.parseHori import parseHori
from parse.parseVerti import parseVerti
from parse.parseRange import parseRange
from urllib2 import Request, urlopen, URLError, HTTPError

from bs4 import BeautifulSoup
from datetime import *

class checkerRules():

    def __init__(self):
        self.scienceKeyWordCSV = parseScienceKeyWord()
        self.instrumentCSV = parseInstrument()
        self.platformCSV = parsePlatform()
        self.projectCSV = parseProjects()
        self.providerCSV = parseProvider()
        self.ruContentType = parseRuncontenttype()
        self.locationsCSV = parseLocations()
        self.HoriCSV = parseHori()
        self.VertiCSV = parseVerti()
        self.RangeCSV = parseRange()
    def converList(self,val):
        listNew = []
        for item in val:
            listNew.append(item.lower())
        return listNew

    def broken_url(self,val):
        if (val != None):
            r = requests.get(val, allow_redirects=False)
            return r.status_code
        else:
            return 404
    #Modified broken_url method to check broken, redirected and valid URLs
    #Modified by Siva
        # try:
        #     urllib2.urlopen(val)
        #     return False
        # except:
        #     return True
        # print "I am checking validity of URLS   " + val
        # try:
        #
        #     #urllib2.urlopen(val)
        #
        #     print "Status Code   " + r.status_code
        #
        # except:
        #     return 404

    def valid_email(self,val):
        if(val == None):
            return False
        return re.search(r'[\w+@\w+]',val) is not None

    def valid_phone(self,val):
        if (val == None):
            return False
        return re.search(r"^((\+\+)d{1}-){0,1}\d{3}-\d{3}-\d{4}$",val) is not None

    def check_Entry_Title(self,metadata):
        val = metadata['Entry_Title']
        shortname = metadata['Entry_ID']['Short_Name']
        if(val == shortname):
            return "The Entry_Title is identical to the Short_Name. Entry_Title maps to \"EntryTitle\" in CMR. Since the entry title is supposed to be a descriptive title of the data set; the Entry_Title should not be the same as the Short_Name."
        temp = 'Recommend that the Dataset Id use mixed case to optimize human readability.'
        if (val.isalnum()): return temp
        if (val.isupper()): return temp
        if (val.islower()): return temp
        return 'OK'

    def check_Dataset_Citation_Dataset_Release_Date(self,val):
        try:
            datetime.strptime(val, '%Y-%m-%d')
            return 'OK'
        except ValueError:
            return 'The recommended format for the dataset_release_date element is yyyy-mm-dd.Recommend changing the dataset_release_date to this format.'

    def check_Dataset_Citation_Persistent_Identifier_Type(self,val):
        temp = ['DOI','ARK']
        if(val == None):
            return 'Please list \'DOI\' as a persistent identifier type. This is required in CMR.'
        if(val not in temp):
            return 'Persistent_Identifier Type + ": invalid persistent identifier type. Please provide a valid type from the following options: DOI, ARK. Note, it is required that each collection records provide a DOI."'
        return 'OK'

    def check_Dataset_Citation_Persistent_Identifier_Identifier(self,val):
        if(val == None):
            return 'Please provide a valid DOI for the dataset as an identifier. This is required in CMR.'
        return 'OK'

    def check_Dataset_Citation_Online_Resource(self, val):
        #if(self.broken_url(val)):
        #    return 'Broken link: ' + val
        #return 'OK'
        ##Added new code to check the broken, redirected and valid URLs
        #Added by Siva
        status = self.broken_url(val)
        if (status >= 400):
            return "Broken link :" + val
        if (status >= 300 and status < 400):
            return "Redirected link :" + val
        if (status == 200):
            return "OK"

    def check_Personnel_Role_item(self,val):
        if(val == None):
            return 'np'
        listItem = ["DATA CENTER CONTACT", "TECHNICAL CONTACT", "SCIENCE CONTACT", "INVESTIGATOR", "METADATA AUTHOR", "USER SERVICES", "SCIENCE SOFTWARE DEVELOPMENT"]
        if(val not in listItem):
            return 'Invalid value for Personnel/Role. The Personnel/Role should be chosen from the following options: DATA CENTER CONTACT;TECHNICAL CONTACT;SCIENCE CONTACT;INVESTIGATOR;METADATA AUTHOR;USER SERVICES;SCIENCE SOFTWARE DEVELOPMENT.'
        else:
            return 'OK'

    def check_Personnel_Contact_Person_Email_item(self,val):
        if(self.valid_email(val)):
            return 'OK'
        return "The email may contain an error. Check to ensure email is provided in the proper form (i.e. \"bobdylan@domain\")"

    def check_Personnel_Contact_Person_phone_item(self,val):
        if(self.valid_phone(val)):
            return 'OK'
        return "The phone number may contain an error(i.e. the phone number may not be in the right form)."

    def check_Personnel_Contact_Person_Phone_Type_item(self,val):
        listItem = ["Direct Line", "Primary", "Telephone", "Fax", "Mobile", "Modem", "TDD/TTY Phone", "U.S. toll free", "Other"]
        if(val == None):
            return 'np'
        if(val not in listItem):
            return "The phone type should come from a predetermined list. Please choose a valid phone type from the following list: Direct Line; Primary; Telephone; Fax; Mobile; Modem; TDD/TTY Phone; U.S. toll free; Other"
        return 'OK'

    def check_Personnel_Contact_Group_Email_item(self,val):
        if (self.valid_email(val)):
            return 'OK'
        return "The email may contain an error. Check to ensure email is provided in the proper form (i.e. \"bobdylan@domain\")"

    def check_Personnel_Contact_Group_Phone_item(self, val):
        if (self.valid_phone(val)):
            return 'OK'
        return "The phone number may contain an error(i.e. the phone number may not be in the right form)."

    def check_Personnel_Contact_Group_Phone_Type_item(self,val):
        listItem = ["Direct Line", "Primary", "Telephone", "Fax", "Mobile", "Modem", "TDD/TTY Phone", "U.S. toll free",
                    "Other"]
        if (val == None):
            return 'np'
        if (val not in listItem):
            return "The phone type should come from a predetermined list. Please choose a valid phone type from the following list: Direct Line; Primary; Telephone; Fax; Mobile; Modem; TDD/TTY Phone; U.S. toll free; Other"
        return 'OK'

    def science_Keywords_item_Category(self,val):
        result = self.scienceKeyWordCSV.getColumn(val)
        if(result == None):
            return "The keyword does not conform to GCMD."
        if(self.scienceKeyWordCSV.getCategory(val)):
            return "OK - quality check"
        else:
            return val + ": is in the incorrect position of the science keyword hierarchy"

    def check_science_Keywords_item_topic(self,val):
        result = self.scienceKeyWordCSV.getColumn(val)
        if(result == None):
            return "The keyword does not conform to GCMD."
        if(self.scienceKeyWordCSV.getTopic(val)):
            return "OK - quality check"
        else:
            return val + ": is in the incorrect position of the science keyword hierarchy"

    def check_science_Keywords_item_Term(self,val):
        result = self.scienceKeyWordCSV.getColumn(val)
        if(result == None):
            return "The keyword does not conform to GCMD."
        if(self.scienceKeyWordCSV.getTerm(val)):
            return "OK - quality check"
        else:
            return val + ": is in the incorrect position of the science keyword hierarchy"

    def check_science_Keywords_item_Variable_1(self,val):
        result = self.scienceKeyWordCSV.getColumn(val)
        if(result == None):
            return "The keyword does not conform to GCMD."
        if(self.scienceKeyWordCSV.getVariable_Level_1(val)):
            return "OK - quality check"
        else:
            return val + ": is in the incorrect position of the science keyword hierarchy"
    def check_science_Keywords_item_Variable_2(self,val):
        result = self.scienceKeyWordCSV.getColumn(val)
        if(result == None):
            return "The keyword does not conform to GCMD."
        if(self.scienceKeyWordCSV.getVariable_Level_2(val)):
            return "OK - quality check"
        else:
            return val + ": is in the incorrect position of the science keyword hierarchy"
    def check_science_Keywords_item_Variable_3(self,val):
        result = self.scienceKeyWordCSV.getColumn(val)
        if(result == None):
            return "The keyword does not conform to GCMD."
        if(self.scienceKeyWordCSV.getVariable_Level_3(val)):
            return "OK - quality check"
        else:
            return val + ": is in the incorrect position of the science keyword hierarchy"

    def check_ISO_Topic_Category(self,val):
        listItem = self.converList(["Farming", "Biota", "Boundaries", "Climatology/Meteorology/Atmosphere", "Economy", "Elevation", "Environment", "Geoscientific Information", "Health", "Imagery/Base Maps/Earth Cover", "Intelligence/Military", "Inland Waters", "Location", "Oceans", "Planning Cadastre", "Society", "Structure", "Transportation", "Utilities/Communications"])

        val = val.lower()
        if(val not in listItem):
            return 'ISO_Topic_Category error. The ISO Topic Category keyword must match a keyword from the following list: Farming; Biota; Boundaries; Climatology/Meteorology/Atmosphere; Economy; Elevation; Environment; Geoscientific Information; Health; Imagery/Base Maps/Earth Cover; Intelligence/Military;Inland Waters; Location; Oceans; Planning Cadastre; Society; Structure; Transportation; Utilities/Communications'
        return "OK"
    def check_Platform_item_Type(self,val):
        result = self.platformCSV.getColumn(val)
        if (result == None):
            return "The keyword does not conform to GCMD."
        if (self.platformCSV.getCategory(val)):
            return "OK - quality check"
        else:
            return val + ": incorrect keyword order."

    def check_Platform_item_Short_Name(self,val):
        result = self.platformCSV.getColumn(val)
        if (result == None):
            return "The keyword does not conform to GCMD."
        if (self.platformCSV.getShortName(val)):
            return "OK - quality check"
        else:
            return val + ": incorrect keyword order."

    def check_Platform_item_Long_Name(self,val):
        if(val == None):
            return 'Recommend adding a platform long name; if applicable.'
        result = self.platformCSV.getColumn(val)
        if (result == None):
            return "The keyword does not conform to GCMD."
        if (self.platformCSV.getLongName(val)):
            return "OK - quality check"
        else:
            return val + ": incorrect keyword order."

    def check_Platform_item_Instrument_item_shortname(self,val):
        result = self.instrumentCSV.getColumn(val)
        if (result == None):
            return "The keyword does not conform to GCMD."
        if (self.instrumentCSV.getShortName(val)):
            return "OK - quality check"
        else:
            return val + ": incorrect keyword order."

    def check_Platform_item_Instrument_item_longname(self,val):
        if(val == None):
            return "Recommend providing an instrument long name since many instrument short names are comprised of acronyms."
        result = self.instrumentCSV.getColumn(val)
        if (result == None):
            return "The keyword does not conform to GCMD."
        if (self.instrumentCSV.getLongName(val)):
            return "OK - quality check"
        else:
            return val + ": incorrect keyword order."

    def check_Platform_item_Instrument_sensor_shortname(self,instrument):
        try:
            val1 = instrument['Short_Name']
            val = instrument['Sensor']['Short_Name']
            if(val1 == val):
                return "Same as instrument short name. Consider removing since this is redundant information."

            result = self.instrumentCSV.getColumn(val)
            if (result == None):
                return "The keyword does not conform to GCMD."
            if (self.instrumentCSV.getShortName(val)):
                return "OK - quality check"
            else:
                return val + ": incorrect keyword order."
        except:
            return 'np'


    def check_Platform_item_Instrument_sensor_longname(self,instrument):
        try:
            val1 = instrument['Long_Name']
            val = instrument['Sensor']['Long_Name']
            if(val1 == val):
                return "Same as instrument long name. Consider removing since this is redundant information."

            result = self.instrumentCSV.getColumn(val)

            if (result == None):
                return "The keyword does not conform to GCMD."
            if (self.instrumentCSV.getLongName(val)):
                return "OK - quality check"
            else:
                return val + ": incorrect keyword order."
        except:
            return 'np'

    def check_Temporal_Coverage_item_Begin_Date_Time(self,val):
        list = ["unknown", "present", "unbounded", "future", "not provided"]
        if(val in list):
            return "OK - quality check"
        try:
            if val == None:
                return "Please provide an beginning date time for this dataset."
            if val.endswith("Z"):
                val = val.replace("Z", "")
                t_record = datetime.strptime(val, '%Y-%m-%dT%H:%M:%S')
                if t_record.microsecond > 999:
                    return "Beginning date time error"
                t_now = datetime.now()
                if t_record > t_now:
                    return "Beginning date time error"
                return "OK - quality check"
            t_record = datetime.strptime(val, '%Y-%m-%d')
            t_now = datetime.now()
            if t_record > t_now:
                return "Beginning date time error"
            return "OK - quality check"
        except ValueError:
            if (val in list):
                return "OK - quality check"
            return "Beginning date time error"

    def check_Temporal_Coverage_item_end_Date_Time(self,val):
        list = ["unknown", "present", "unbounded", "future", "not provided"]
        if(val in list):
            return "OK - quality check"
        try:
            if val == None:
                return "Please provide an Ending date time for this dataset."
            if val.endswith("Z"):
                val = val.replace("Z", "")
                t_record = datetime.strptime(val, '%Y-%m-%dT%H:%M:%S')
                if t_record.microsecond > 999:
                    return "Ending date time error"
                t_now = datetime.now()
                if t_record > t_now:
                    return "Ending date time error"
                return "OK - quality check"
            t_record = datetime.strptime(val, '%Y-%m-%d')
            t_now = datetime.now()
            if t_record > t_now:
                return "Ending date time error"
            return "OK - quality check"
        except ValueError:
            if (val in list):
                return "OK - quality check"
            return "Ending date time error"

    def check_dataset_progress(self,val):
        listItem = ["PLANNED", "IN WORK", "COMPLETE"]
        if(val == None):
            return 'np - This element is now required in CMR. Please provide a value indicating the state of the collection from one of the following options: PLANNED; IN WORK; COMPLETE'
        if(val not in listItem):
            return "Invalid value for Dataset_Progress. Choose a valid value from the following list: PLANNED; IN WORK; COMPLETE"
        return "OK - quality check"

    def check_Spatial_Coverage_Granule_Spatial_Representation(self,val):
        listItem = ["CARTESIAN", "GEODETIC", "ORBIT", "NO_SPATIAL"]
        if(val == None):
            return "This is a required element. Provide a value for Granule_Spatial_Representation from the following options: CARTESIAN; GEODETIC; ORBIT; NO_SPATIAL"
        if(val not in listItem):
            return "Invalid value for Granule_Spatial_Representation. Choose a valid value from the following list: CARTESIAN;GEODETIC;ORBIT;NO_SPATIAL"
        return "OK"

    def check_Spatial_Coverage_Geometry_Coordinate_System(self,val):
        listItem = ["CARTESIAN", "GEODETIC"]
        if(val == None):
            return 'np'
        if(val not in listItem):
            return "Invalid value for Geometry/Coordinate_System. Choose a valid option from the following: CARTESIAN; GEODETIC"
        return "OK"

    def check_Spatial_Coverage_Geometry_Bounding_Rectangle_Southernmost_Latitude(self,Bounding_Rectangle):
        if(Bounding_Rectangle['Southernmost_Latitude'] < Bounding_Rectangle['Northernmost_Latitude']):
            return "OK - quality check"
        return "The north and south bounding coordinates may have been switched."

    def check_Spatial_Coverage_Geometry_Bounding_Rectangle_Northernmost_Latitude(self,Bounding_Rectangle):
        if (Bounding_Rectangle['Southernmost_Latitude'] < Bounding_Rectangle['Northernmost_Latitude']):
            return "OK - quality check"
        return "The north and south bounding coordinates may have been switched."

    def check_Spatial_Coverage_Geometry_Bounding_Rectangle_Westernmost_Longitude(self, Bounding_Rectangle):
        if (Bounding_Rectangle['Westernmost_Longitude'] < Bounding_Rectangle['Easternmost_Longitude']):
            return "OK - quality check"
        return "The east and west bounding coordinates may have been switched."

    def check_Spatial_Coverage_Geometry_Bounding_Rectangle_Easternmost_Longitude(self, Bounding_Rectangle):
        if (Bounding_Rectangle['Westernmost_Longitude'] < Bounding_Rectangle['Easternmost_Longitude']):
            return "OK - quality check"
        return "The east and west bounding coordinates may have been switched."
    def check_Location_Location_Category(self,val):
        if(val == None):
            return 'np'
        result = self.locationsCSV.getColumn(val)

        if(result == None):
            return 'The spatial keyword ' + val + " is not listed in GCMD; or contains an error."

        if(self.locationsCSV.getLocation_Category(val)):
            return 'OK'
        return val + ':incorrect keyword order'

    def check_Location_Location_Type(self,val):
        if(val == None):
            return "np"
        result = self.locationsCSV.getColumn(val)

        if(result == None):
            return 'The spatial keyword ' + val + " is not listed in GCMD; or contains an error."

        if(self.locationsCSV.getLocation_Type(val)):
            return 'OK'
        return val + ':incorrect keyword order'

    def check_Location_Subregion1(self,val):
        if(val == None):
            return "np"
        result = self.locationsCSV.getColumn(val)

        if(result == None):
            return 'The spatial keyword ' + val + " is not listed in GCMD; or contains an error."

        if(self.locationsCSV.getLocation_Subregion1(val)):
            return 'OK'
        return val + ':incorrect keyword order'

    def check_Location_Subregion2(self,val):
        if(val == None):
            return "np"
        result = self.locationsCSV.getColumn(val)

        if(result == None):
            return 'The spatial keyword ' + val + " is not listed in GCMD; or contains an error."

        if(self.locationsCSV.getLocation_Subregion2(val)):
            return 'OK'
        return val + ':incorrect keyword order'

    def check_Location_Subregion3(self,val):
        if(val == None):
            return "np"
        result = self.locationsCSV.getColumn(val)

        if(result == None):
            return 'The spatial keyword ' + val + " is not listed in GCMD; or contains an error."

        if(self.locationsCSV.getLocation_Subregion3(val)):
            return 'OK'
        return val + ':incorrect keyword order'

    def check_Horizontal_Resolution_Range(self,val):
        if(val == None):
            return 'np'
        result = self.HoriCSV.getColumn(val)

        if(result == None):
            return "The Horizontal_Resolution_Range keyword " + val + " is not listed in GCMD; or contains an error."
        return "OK"

    def check_Vertical_Resolution_Range(self,val):
        if(val == None):
            return 'np'
        result = self.VertiCSV.getColumn(val)

        if(result == None):
            return "The Vertical_Resolution_Range keyword " + val + " is not listed in GCMD; or contains an error."

        return "OK"

    def check_Temporal_Resolution_Range(self,val):
        if (val == None):
            return 'np'
        result = self.RangeCSV.getColumn(val)

        if (result == None):
            return "The Temporal_Resolution_Range " + val + " is not listed in GCMD; or contains an error."

        return "OK"

    def check_Project_Short_Name(self,val):
        result = self.projectCSV.getColumn(val)
        if (result == None):
            return "The project short name does not conform to GCMD."
        if (self.projectCSV.getShortName(val)):
            return "OK - quality check"
        else:
            return result + ": incorrect keyword order."

    def check_Project_Long_Name(self,val):
        result = self.projectCSV.getColumn(val)
        if (result == None):
            return "The project short name does not conform to GCMD."
        if (self.projectCSV.getLongName(val)):
            return "OK - quality check"
        else:
            return result + ": incorrect keyword order."

    def check_Quality(self,val):
        if val == None:
            return "np"
        return "OK"

    def check_Dataset_Language(self,val):
        listItem = ["English", "Afrikaans", "Arabic", "Bosnia", "Bulgarian", "Chinese", "Croation", "Czech", "Danish", "Dutch", "Estonian", "Finnish", "French", "German", "Hebrew", "Hungarian", "Indonesian", "Italian", "Japanese", "Korean", "Latvian", "Lithuanian", "Norwegian", "Polish", "Portuguese", "Romanian", "Russian", "Slovak", "Spanish", "Ukrainian", "Vietnamese"]
        if(val == None):
            return 'np'
        if(val not in listItem):
            return "The data set language provided is not a valid language keyword keyword. Please choose an appropriate language from the following keyword list: English; Afrikaans; Arabic; Bosnia; Bulgarian; Chinese; Croation; Czech; Danish; Dutch; Estonian; Finnish; French; German; Hebrew; Hungarian; Indonesian; Italian; Japanese; Korean; Latvian; Lithuanian; Norwegian; Polish; Portuguese; Romanian; Russian; Slovak; Spanish; Ukrainian; Vietnamese"
        return "OK"
    def check_Organization_Organization_Type(self,val):
        listItem = ["ARCHIVER", "DISTRIBUTOR", "ORIGINATOR", "PROCESSOR"]
        if(val == None):
            return 'np - This is a required field. Provide one of the following values as the Organization_Type: ARCHIVER; DISTRIBUTOR; ORIGINATOR; PROCESSOR'
        if(val not in listItem):
            return "Invalid value for Organization_Type. Choose a valid value from the following list: ARCHIVER; DISTRIBUTOR; ORIGINATOR; PROCESSOR"
        return "OK"

    def check_Organization_Name_Short_Name(self,val):
        result = self.providerCSV.getColumn(val)
        if (result == None):
            return "It is recommended that the Organization Short Name be compliant with GCMD vocabulary. Choose a valid Organization Short Name name from the following list: https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/providers?format=csv All records from the same DAAC should have the same Organization Short Name for consistency."
        if (self.providerCSV.getShortName(val)):
            return "OK - quality check"
        else:
            return result + ": incorrect keyword order."

    def check_Organization_Name_Long_Name(self,val):
        if(val == None):
            return "np - Recommend providing an Organization Long Name if applicable."
        result = self.providerCSV.getColumn(val)
        if(result == None):
            "It is recommended that the Organization Long Name be compliant with GCMD vocabulary. Choose a valid Organization Long Name name from the following list: https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/providers?format=csv All records from the same DAAC should have the same Organization Long Name for consistency."
        if(self.providerCSV.getLongName(val)):
            return val + ": incorrect position in hierarchy"
        return "OK"

    def check_Organization_Personnel_Contact_Person_Phone_Type(self,val):

        listItem = ["Direct Line", "Primary", "Telephone", "Fax", "Mobile", "Modem", "TDD/TTY Phone",
                    "U.S. toll free", "Other"]
        if (val == None):
            return 'np'
        if (val not in listItem):
            return "The phone type should come from a predetermined list. Please choose a valid phone type from the following list: Direct Line; Primary; Telephone; Fax; Mobile; Modem; TDD/TTY Phone; U.S. toll free; Other"
        return 'OK'

    def check_Organization_Personnel_Contact_Group_Phone_Type(self,val):

        listItem = ["Direct Line", "Primary", "Telephone", "Fax", "Mobile", "Modem", "TDD/TTY Phone",
                    "U.S. toll free", "Other"]
        if (val == None):
            return 'np'
        if (val not in listItem):
            return "The phone type should come from a predetermined list. Please choose a valid phone type from the following list: Direct Line; Primary; Telephone; Fax; Mobile; Modem; TDD/TTY Phone; U.S. toll free; Other"
        return 'OK'

    def check_Distribution_Distribution_Format(self,val):
        listItem = ["hdf", "netcdf", "geotiff", "gml", "geography markup language"]

        if(val == None):
            return "Recommend providing the Distribution_Format for this data set. If there is more than one Distribution_Format each should be listed as a separate element."
        if(val.lower() not in listItem):
            return "OK - Distribution_Format does not meet framework requirements (i.e. the data is not in one of the following framework approved formats; HDF; NetCDF; GeoTIFF or Geography Markup Language)."
        return "OK - " + val

    def check_Multimedia_Sample_URL(self,val):
        #Added code to check broken, redirected and valid URLs.
        #Coded by Siva
        if(val == None):
            return 'np'
        status = self.broken_url(val)
        if(status>=400):
            return "Broken link :" + val
        if (status >= 300 and status < 400):
            return "Redirected link :" + val
        if(status == 200):
            return "OK"

    def check_summary_abstract(self,val):
        result = ""
        if(len(val) > 500):
            result += "OK - quality check;"
        else:
            result += "Dataset abstract may be inadequate based on length. "

        urls = re.findall("(?P<url>https?://[^\s]+)",val)
        for item in urls:
            #if (self.broken_url(item)):
            #    result +='Broken link: ' + item + ";"
            #Added code to check broken, redirected and valid URLs
            #Coded by Siva
            status = self.broken_url(val)
            if (status >= 400):
                return "Broken link :" + val
            if (status >= 300 and status < 400):
                return "Redirected link :" + val

        if(bool(BeautifulSoup(val,"html.parser").find())):
            result += " The abstract contains HTML. Please verify the HTML entities are being displayed properly."

        return result

    def check_Related_URL_item_Content_Type(self,val):
        if(val == None):
            return "Provide a URL type for all Related URLs. Choose a type from the following list: https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/rucontenttype?format=csv"

        if (self.ruContentType.getType(val)):
            if(val.lower() == 'get data'):
                return "0"
            return "1"
        else:
            return "Invalid types: " + val + "URL Types are translated to GCMD vocabulary in CMR. In order to avoid translation errors please choose an appropriate URL Content Type from the following keywords list: https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/rucontenttype?format=csv"

    def check_Related_URL_Content_Type(self,val):
        val = val.split(';')
        result = ''
        flag = 0
        for item in val:
            if(item == "0"  and flag != 2):
                flag = 1
            elif(item != '1'):
                result += item + ';'
                flag = 2

        if(flag == 2): return result
        if(flag == 1): return 'OK'
        return "OK - no GET DATA link is provided"

    def check_Related_URL_Content_Type_SubType(self,val):
        listA = ["THREDDS CATALOG", "THREDDS DATA", "THREDDS DIRECTORY", "GET WEB MAP FOR TIME SERIES", "GET RELATED VISUALIZATION", "GIOVANNI", "WORLDVIEW", "GET MAP SERVICE"]
        listB = ["GET WEB MAP SERVICE (WMS)", "GET WEB COVERAGE SERVICE (WCS)", "OPENDAP DATA (DODS)"]

        listA = self.converList(listA)
        listB = self.converList(listB)

        if(val == None):
            return 'np'
        result = self.ruContentType.getColumn(val)
        if(result == None):
            return "Invalid types: " + val + "URL Types are translated to GCMD vocabulary in CMR. In order to avoid translation errors; please choose an appropriate URL Content Type subtype from the following keywords list: https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/rucontenttype?format=csv"
        if(self.ruContentType.getSubType(val)):
            if(val.lower() in listA):
                return "OK - one point for data accessability score for providing an advanced service for visualization subsetting or aggregation"
            if(val.lower() in listB):
                return "OK - two points for data accessability score for providing an advanced service for visualization subsetting or aggregation which also meets common framework requirements for standard API based data access."
            return 'OK'
        return "Incorrect keyword order: " + val

    def check_Related_URL_Description_Item(self,val):
        if(val == None):
            return "False"
        return "True"

    def check_Related_URL_Description(self,val):
        val = val.split(';')
        for item in val:
            if(item == "False"):
                return 'Recommend providing descriptions for all Related URLs'
        return "OK - quality check"

    def check_Related_URL_Mime_Type(self,val):
        listItem = ["application/json", "application/xml", "application/x-netcdf", "application/gml+xml", "application/vnd.google-earch.kml+xml", "application/pdf", "application/x-hdf", "application/xhdf5", "application/octet-stream", "application/vnd.google-earth.kmz", "image/gif", "image/tiff", "image/bmp", "image/jpeg", "image/png", "image/vnd.collada+xml", "text/csv", "text/xml", "text/html", "text/plain"]

        try:
            type = val.URL_Content_Type.Type
            if(type != "GET SERVICE"):
                return ""
        except:
            return ""
        try:
            if(val.Mime_Type == None):
                return 'According to UMM-Common documentation; mime types are currently only required for links that are labeled \'Get Service\'. This requirement may change.'
            if(val.Mime_Type.lower() not in listItem):
                return "Invalid mime type for GET SERVICE"
            else:
                return "OK"
        except:
            return 'According to UMM-Common documentation; mime types are currently only required for links that are labeled \'Get Service\'. This requirement may change.'
    def convertMimeType(self,val):
        val = val.split(';')
        result = ''
        for item in val:
            if(item != ''):
                result += item + ';'
        return result

    def check_Product_Level_ID(self,val):
        if(val != None):
            return "OK - quality check"
        else:
            return "A product level ID is required for all EOSDIS collections in CMR. Please choose an appropriate processing level from the following list: https://science.nasa.gov/earth-science/earth-science-data/data-processing-levels-for-eosdis-data-products/"

    def check_Collection_Data_Type(self,val):
        listItem = ["SCIENCE_QUALITY", "NEAR_REAL_TIME", "OTHER"]
        if(val == None):
            return "np"
        if(val not in listItem):
            return "Invalid value for Collection_Data_Type. Chose a valid value from the following options: SCIENCE_QUALITY; NEAR_REAL_TIME; OTHER"
        return "OK"

    def check_dateFormat(self,val,str):
        list = ["unknown", "present", "unbounded", "future", "not provided"]
        if (val in list):
            return "OK - quality check;"
        try:
            if val == None:
                return str
            if val.endswith("Z"):
                val = val.replace("Z", "")
                t_record = datetime.strptime(val, '%Y-%m-%dT%H:%M:%S')
                if t_record.microsecond > 999:
                    return str
                t_now = datetime.now()
                if t_record > t_now:
                    return str
                return "OK - quality check;"
            t_record = datetime.strptime(val, '%Y-%m-%d')
            t_now = datetime.now()
            if t_record > t_now:
                return str
            return "OK - quality check;"
        except ValueError:
            if (val in list):
                return "OK - quality check;"
            return str

    def check_Metadata_Dates_Creation(self,val):
        return self.check_dateFormat(val,"Metadata_Creation date/time error.")

    def check_Metadata_last_revision(self,val):
        return self.check_dateFormat(val,"Metadata_Last_Revision date/time error.")

    def check_Metadata_data_creation(self,val):
        return self.check_dateFormat(val,"Data_Creation date/time error.")

    def check_Metadata_data_latest_revision(self,val):
        return self.check_dateFormat(val,"Data_Last_Revision date/time error.")



