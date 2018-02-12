'''This file is for get CSV output for Collection DIF data'''

class DIFOutputCSV():
    def __init__(self,checkerRules,wrap):
        self.checkerRules = checkerRules
        self.wrap = wrap

    def checkAll(self, metadata):
        result = ",,,"
        try:
            result += self.checkerRules.check_Entry_Title(metadata) + ','
        except:
            result += 'np' + ','
        result += ",,,,"
        try:
            result += self.wrap(metadata,self.checkerRules.check_Dataset_Citation_Dataset_Release_Date,'Dataset_Citation.Dataset_Release_Date') + ','
        except:
            result += 'np' + ','
        result += ",,,,,,"
        try:
            result += self.wrap(metadata,self.checkerRules.check_Dataset_Citation_Persistent_Identifier_Type,'Dataset_Citation.Persistent_Identifier.Type') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Dataset_Citation_Persistent_Identifier_Identifier,'Dataset_Citation.Persistent_Identifier.Identifier') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Dataset_Citation_Online_Resource,'Dataset_Citation.Online_Resource') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Personnel_Role_item,'Personnel.Role') + ','
        except:
            result += 'np' + ','

        result += ",,,,,,,,"
        try:
            result += self.wrap(metadata, self.checkerRules.check_Personnel_Contact_Person_Email_item, 'Personnel.Contact_Person.Email')
        except:
            result += 'np'
        result += ','
        try:
            result += self.wrap(metadata, self.checkerRules.check_Personnel_Contact_Person_phone_item, 'Personnel.Contact_Person.Phone.Number') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Personnel_Contact_Person_Phone_Type_item,'Personnel.Contact_Person.Phone.Type') + ','
        except:
            result += 'np' + ','
        result += ",,,,,,"
        try:
            result += self.wrap(metadata,self.checkerRules.check_Personnel_Contact_Group_Email_item,'Personnel.Contact_Group.Email') + ","
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Personnel_Contact_Group_Phone_item,'Personnel.Contact_Group.Phone.Number') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Personnel_Contact_Group_Phone_Type_item,'Personnel.Contact_Group.Phone.Type') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.science_Keywords_item_Category,'Science_Keywords.Category') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_science_Keywords_item_topic,'Science_Keywords.Topic') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_science_Keywords_item_Term,'Science_Keywords.Term') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_science_Keywords_item_Variable_1,'Science_Keywords.Variable_Level_1') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_science_Keywords_item_Variable_2,'Science_Keywords.Variable_Level_2') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata, self.checkerRules.check_science_Keywords_item_Variable_3,'Science_Keywords.Variable_Level_3') + ','
        except:
            result += 'np' + ','
        result += ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_ISO_Topic_Category,'ISO_Topic_Category') + ','
        except:
            result += 'np' + ','
        result += ','
        try:
            result += self.wrap(metadata, self.checkerRules.check_Platform_item_Type, 'Platform.Type') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Platform_item_Short_Name,'Platform.Short_Name') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Platform_item_Long_Name,'Platform.Long_Name') + ','
        except:
            result += 'np' + ','
        result += ",,,,,"
        try:
            result += self.wrap(metadata,self.checkerRules.check_Platform_item_Instrument_item_shortname,'Platform.Instrument.Short_Name') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Platform_item_Instrument_item_longname,'Platform.Instrument.Long_Name') + ','
        except:
            result += 'np' + ','
        result += ",,,,,,,,"
        try:
            result += self.wrap(metadata,self.checkerRules.check_Platform_item_Instrument_sensor_shortname,'Platform.Instrument') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Platform_item_Instrument_sensor_longname,'Platform.Instrument') + ','
        except:
            result += 'np' + ','

        result += ",,,,,,,,,,,"

        try:
            result += self.wrap(metadata,self.checkerRules.check_Temporal_Coverage_item_Begin_Date_Time,'Temporal_Coverage.Range_DateTime.Beginning_Date_Time') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Temporal_Coverage_item_end_Date_Time,'Temporal_Coverage.Range_DateTime.Ending_Date_Time') + ','
        except:
            result += 'np' + ','

        result += ',,,,,,,,,,,,,,,,,'
        try:
            result += self.wrap(metadata,self.checkerRules.check_dataset_progress,'Dataset_Progress') +','
        except:
            result += 'np' + ','
        result += ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Spatial_Coverage_Granule_Spatial_Representation,'Spatial_Coverage.Granule_Spatial_Representation') + ','
        except:
            result += 'np' + ','
        result += ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Spatial_Coverage_Geometry_Coordinate_System,'Spatial_Coverage.Geometry.Coordinate_System') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Spatial_Coverage_Geometry_Bounding_Rectangle_Southernmost_Latitude,'Spatial_Coverage.Geometry.Bounding_Rectangle') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Spatial_Coverage_Geometry_Bounding_Rectangle_Northernmost_Latitude,'Spatial_Coverage.Geometry.Bounding_Rectangle') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Spatial_Coverage_Geometry_Bounding_Rectangle_Westernmost_Longitude,'Spatial_Coverage.Geometry.Bounding_Rectangle') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Spatial_Coverage_Geometry_Bounding_Rectangle_Easternmost_Longitude,'Spatial_Coverage.Geometry.Bounding_Rectangle') + ','
        except:
            result += 'np' + ','
        result += ',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,'
        try:
            result += self.wrap(metadata,self.checkerRules.check_Location_Location_Category,'Location.Location_Category') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Location_Location_Type,'Location.Location_Type') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Location_Subregion1,'Location.Location_Subregion1') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Location_Subregion2,'Location.Location_Subregion2') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata, self.checkerRules.check_Location_Subregion3, 'Location.Location_Subregion3') + ','
        except:
            result += 'np' + ','
        result += ',,,'
        try:
            result += self.wrap(metadata,self.checkerRules.check_Horizontal_Resolution_Range,'Data_Resolution.Horizontal_Resolution_Range') + ','
        except:
            result += 'np' + ','
        result += ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Vertical_Resolution_Range,'Data_Resolution.Vertical_Resolution_Range') + ','
        except:
            result += 'np' + ','
        result += ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Temporal_Resolution_Range,'Data_Resolution.Temporal_Resolution_Range') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Project_Short_Name,'Project.Short_Name') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Project_Long_Name,'Project.Long_Name') + ','
        except:
            result += 'np' + ','
        result += ',,,'
        try:
            result += self.wrap(metadata,self.checkerRules.check_Quality,'Quality') + ','
        except:
            result += 'np' + ','
        result += ',,'
        try:
            result += self.wrap(metadata,self.checkerRules.check_Dataset_Language,'Dataset_Language') + ','
        except:
            result += 'np' + ','
        result += ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Organization_Organization_Type,'Organization.Organization_Type') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Organization_Name_Short_Name,'Organization.Organization_Name.Short_Name') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Organization_Name_Long_Name,'Organization.Organization_Name.Long_Name') + ','
        except:
            result += 'np' + ','
        result += ',,,,,,,,,,,,,,,'
        try:
            result += self.wrap(metadata,self.checkerRules.check_Organization_Personnel_Contact_Person_Phone_Type,'Organization.Personnel.Contact_Person.Phone.Type') + ','
        except:
            result += 'np' + ','
        result += ',,,,,,,,'
        try:
            result += self.wrap(metadata, self.checkerRules.check_Organization_Personnel_Contact_Person_Phone_Type,'Organization.Personnel.Contact_Group.Phone.Type') + ','
        except:
            result += 'np' + ','
        result += ',,'
        try:
            result += self.wrap(metadata,self.checkerRules.check_Distribution_Distribution_Format,'Distribution.Distribution_Format') + ','
        except:
            result += 'np' + ','
        result += ',,'
        try:
            result += self.wrap(metadata,self.checkerRules.check_Multimedia_Sample_URL,'Multimedia_Sample.URL') + ','
        except:
            result += 'np' + ','
        result += ',,,,,,,,,,,,,,,,,,,,'
        try:
            result += self.wrap(metadata,self.checkerRules.check_summary_abstract,'Summary.Abstract') + ','
        except:
            result += 'np' + ','
        result += ','
        try:
            temp = self.wrap(metadata,self.checkerRules.check_Related_URL_item_Content_Type,'Related_URL.URL_Content_Type.Type')
            result += self.checkerRules.check_Related_URL_Content_Type(temp) + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Related_URL_Content_Type_SubType,'Related_URL.URL_Content_Type.Subtype') + ','
        except:
            result += 'np' + ','
        result += ',,,'
        try:
            temp = self.wrap(metadata,self.checkerRules.check_Related_URL_Description_Item,'Related_URL.Description')
            result += self.checkerRules.check_Related_URL_Description(temp) + ','
        except:
            result += 'np' + ','
        try:
            temp = self.wrap(metadata,self.checkerRules.check_Related_URL_Mime_Type,'Related_URL')
            result += self.checkerRules.convertMimeType(temp) + ','
        except:
            result += 'np' + ','

        result += ',,,,,,,,,,,,,,'
        try:
            result += self.wrap(metadata,self.checkerRules.check_Product_Level_ID,'Product_Level_Id') + ','
        except:
            result += 'np' + ','
        result += ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Collection_Data_Type,'Collection_Data_Type') + ','
        except:
            result += 'np' + ','
        result += ',,,,'
        try:
            result += self.wrap(metadata,self.checkerRules.check_Metadata_Dates_Creation,'Metadata_Dates.Metadata_Creation') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Metadata_last_revision,'Metadata_Dates.Metadata_Last_Revision') + ','
        except:
            result += 'np' + ','
        result += ',,'
        try:
            result += self.wrap(metadata, self.checkerRules.check_Metadata_data_creation,'Metadata_Dates.Data_Creation') + ','
        except:
            result += 'np' + ','
        try:
            result += self.wrap(metadata,self.checkerRules.check_Metadata_data_latest_revision,'Metadata_Dates.Data_Last_Revision') + ','
        except:
            result += 'np' + ','
        return result
