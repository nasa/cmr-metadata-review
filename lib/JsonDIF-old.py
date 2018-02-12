'''This file is for get JSON output for Collection DIF data'''

class DIFOutputJSON():
    def __init__(self,checkerRules,wrap):
        self.checkerRules = checkerRules
        self.wrap = wrap

    def checkAll(self, metadata):
        result = {}
        #=======================================
        str = 'Entry_Title'
        try:
            result[str] = self.checkerRules.check_Entry_Title(metadata)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Dataset_Citation.Dataset_Release_Date'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Dataset_Citation_Dataset_Release_Date,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Dataset_Citation.Persistent_Identifier.Type'
        try:
            result[str] = self.wrap(metadata, self.checkerRules.check_Dataset_Citation_Persistent_Identifier_Type,'Dataset_Citation.Persistent_Identifier.Type')
        except:
            result[str] = 'np'
        # ======================================
        str = 'Dataset_Citation.Persistent_Identifier.Identifier'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Dataset_Citation_Persistent_Identifier_Identifier,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Dataset_Citation.Online_Resource'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Dataset_Citation_Online_Resource,'Dataset_Citation.Online_Resource')
        except:
            result[str] = 'np'
        # ======================================
        str = 'Personnel.Role'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Personnel_Role_item,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Personnel.Contact_Person.Email'
        try:
            result[str] = self.wrap(metadata, self.checkerRules.check_Personnel_Contact_Person_Email_item, str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Personnel.Contact_Person.Phone.Number'
        try:
            result[str] = self.wrap(metadata, self.checkerRules.check_Personnel_Contact_Person_phone_item, str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Personnel.Contact_Person.Phone.Type'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Personnel_Contact_Person_Phone_Type_item,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Personnel.Contact_Group.Email'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Personnel_Contact_Group_Email_item,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Personnel.Contact_Group.Phone.Number'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Personnel_Contact_Group_Phone_item,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Personnel.Contact_Group.Phone.Type'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Personnel_Contact_Group_Phone_Type_item,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Science_Keywords.Category'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.science_Keywords_item_Category,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Science_Keywords.Topic'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_science_Keywords_item_topic,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Science_Keywords.Term'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_science_Keywords_item_Term,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Science_Keywords.Variable_Level_1'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_science_Keywords_item_Variable_1,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Science_Keywords.Variable_Level_2'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_science_Keywords_item_Variable_2,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Science_Keywords.Variable_Level_3'
        try:
            result[str] = self.wrap(metadata, self.checkerRules.check_science_Keywords_item_Variable_3,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'ISO_Topic_Category'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_ISO_Topic_Category,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Platform.Type'
        try:
            result[str] = self.wrap(metadata, self.checkerRules.check_Platform_item_Type,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Platform.Short_Name'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Platform_item_Short_Name,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Platform.Long_Name'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Platform_item_Long_Name,str)
        except:
            result[str] = 'np'

        # ======================================
        str = 'Platform.Instrument.Short_Name'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Platform_item_Instrument_item_shortname,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Platform.Instrument.Long_Name'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Platform_item_Instrument_item_longname,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Platform.Instrument'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Platform_item_Instrument_sensor_shortname,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Platform.Instrument'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Platform_item_Instrument_sensor_longname,str)
        except:
            result[str] = 'np'

        # ======================================
        str = 'Temporal_Coverage.Range_DateTime.Beginning_Date_Time'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Temporal_Coverage_item_Begin_Date_Time,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Temporal_Coverage.Range_DateTime.Ending_Date_Time'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Temporal_Coverage_item_end_Date_Time,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Dataset_Progress'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_dataset_progress,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Spatial_Coverage.Granule_Spatial_Representation'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Spatial_Coverage_Granule_Spatial_Representation,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Spatial_Coverage.Geometry.Coordinate_System'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Spatial_Coverage_Geometry_Coordinate_System,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Spatial_Coverage.Geometry.Bounding_Rectangle'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Spatial_Coverage_Geometry_Bounding_Rectangle_Southernmost_Latitude,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Spatial_Coverage.Geometry.Bounding_Rectangle'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Spatial_Coverage_Geometry_Bounding_Rectangle_Northernmost_Latitude,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Spatial_Coverage.Geometry.Bounding_Rectangle'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Spatial_Coverage_Geometry_Bounding_Rectangle_Westernmost_Longitude,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Spatial_Coverage.Geometry.Bounding_Rectangle'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Spatial_Coverage_Geometry_Bounding_Rectangle_Easternmost_Longitude,str)
        except:
            result[str] = 'np'

        # ======================================
        str = 'Location.Location_Category'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Location_Location_Category,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Location.Location_Type'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Location_Location_Type,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Location.Location_Subregion1'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Location_Subregion1,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Location.Location_Subregion2'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Location_Subregion2,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Location.Location_Subregion3'
        try:
            result[str] = self.wrap(metadata, self.checkerRules.check_Location_Subregion3, str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Data_Resolution.Horizontal_Resolution_Range'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Horizontal_Resolution_Range,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Data_Resolution.Vertical_Resolution_Range'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Vertical_Resolution_Range,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Data_Resolution.Temporal_Resolution_Range'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Temporal_Resolution_Range,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Project.Short_Name'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Project_Short_Name,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Project.Long_Name'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Project_Long_Name,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Quality'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Quality,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Dataset_Language'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Dataset_Language,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Organization.Organization_Type'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Organization_Organization_Type,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Organization.Organization_Name.Short_Name'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Organization_Name_Short_Name,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Organization.Organization_Name.Long_Name'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Organization_Name_Long_Name,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Organization.Personnel.Contact_Person.Phone.Type'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Organization_Personnel_Contact_Person_Phone_Type,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Organization.Personnel.Contact_Group.Phone.Type'
        try:
            result[str] = self.wrap(metadata, self.checkerRules.check_Organization_Personnel_Contact_Person_Phone_Type,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Distribution.Distribution_Format'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Distribution_Distribution_Format,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Multimedia_Sample.URL'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Multimedia_Sample_URL,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Summary.Abstract'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_summary_abstract,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Related_URL.URL_Content_Type.Type'
        try:
            temp = self.wrap(metadata,self.checkerRules.check_Related_URL_item_Content_Type,str)
            result[str] = self.checkerRules.check_Related_URL_Content_Type(temp)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Related_URL.URL_Content_Type.Subtype'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Related_URL_Content_Type_SubType,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Related_URL.Description'
        try:
            temp = self.wrap(metadata,self.checkerRules.check_Related_URL_Description_Item,str)
            result[str] += self.checkerRules.check_Related_URL_Description(temp)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Related_URL'
        try:
            temp = self.wrap(metadata,self.checkerRules.check_Related_URL_Mime_Type,str)
            result[str] = self.checkerRules.convertMimeType(temp)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Product_Level_Id'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Product_Level_ID,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Collection_Data_Type'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Collection_Data_Type,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Metadata_Dates.Metadata_Creation'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Metadata_Dates_Creation,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Metadata_Dates.Metadata_Last_Revision'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Metadata_last_revision,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Metadata_Dates.Data_Creation'
        try:
            result[str] = self.wrap(metadata, self.checkerRules.check_Metadata_data_creation,str)
        except:
            result[str] = 'np'
        # ======================================
        str = 'Metadata_Dates.Data_Last_Revision'
        try:
            result[str] = self.wrap(metadata,self.checkerRules.check_Metadata_data_latest_revision,str)
        except:
            result[str] = 'np'

        return result