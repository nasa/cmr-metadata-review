"""
This file is for generating JSON output for Collection DIF data.
"""

class DIFOutputJSON:
    def __init__(self, checker_rules, wrap):
        self.checker_rules = checker_rules
        self.wrap = wrap

    def check_all(self, metadata):
        result = {}
        checks = [
            ('Entry_Title', self.checker_rules.check_Entry_Title),
            ('Dataset_Citation.Dataset_Release_Date', self.checker_rules.check_Dataset_Citation_Dataset_Release_Date),
            ('Dataset_Citation.Persistent_Identifier.Type', self.checker_rules.check_Dataset_Citation_Persistent_Identifier_Type),
            ('Dataset_Citation.Persistent_Identifier.Identifier', self.checker_rules.check_Dataset_Citation_Persistent_Identifier_Identifier),
            ('Dataset_Citation.Online_Resource', self.checker_rules.check_Dataset_Citation_Online_Resource),
            ('Personnel.Role', self.checker_rules.check_Personnel_Role_item),
            ('Personnel.Contact_Person.Email', self.checker_rules.check_Personnel_Contact_Person_Email_item),
            ('Personnel.Contact_Person.Phone.Number', self.checker_rules.check_Personnel_Contact_Person_phone_item),
            ('Personnel.Contact_Person.Phone.Type', self.checker_rules.check_Personnel_Contact_Person_Phone_Type_item),
            ('Personnel.Contact_Group.Email', self.checker_rules.check_Personnel_Contact_Group_Email_item),
            ('Personnel.Contact_Group.Phone.Number', self.checker_rules.check_Personnel_Contact_Group_Phone_item),
            ('Personnel.Contact_Group.Phone.Type', self.checker_rules.check_Personnel_Contact_Group_Phone_Type_item),
            ('Science_Keywords.Category', self.checker_rules.science_Keywords_item_Category),
            ('Science_Keywords.Topic', self.checker_rules.check_science_Keywords_item_topic),
            ('Science_Keywords.Term', self.checker_rules.check_science_Keywords_item_Term),
            ('Science_Keywords.Variable_Level_1', self.checker_rules.check_science_Keywords_item_Variable_1),
            ('Science_Keywords.Variable_Level_2', self.checker_rules.check_science_Keywords_item_Variable_2),
            ('Science_Keywords.Variable_Level_3', self.checker_rules.check_science_Keywords_item_Variable_3),
            ('ISO_Topic_Category', self.checker_rules.check_ISO_Topic_Category),
            ('Platform.Type', self.checker_rules.check_Platform_item_Type),
            ('Platform.Short_Name', self.checker_rules.check_Platform_item_Short_Name),
            ('Platform.Long_Name', self.checker_rules.check_Platform_item_Long_Name),
            ('Platform.Instrument.Short_Name', self.checker_rules.check_Platform_item_Instrument_item_shortname),
            ('Platform.Instrument.Long_Name', self.checker_rules.check_Platform_item_Instrument_item_longname),
            ('Platform.Instrument', self.checker_rules.check_Platform_item_Instrument_sensor_shortname),
            ('Platform.Instrument', self.checker_rules.check_Platform_item_Instrument_sensor_longname),
            ('Temporal_Coverage.Range_DateTime.Beginning_Date_Time', self.checker_rules.check_Temporal_Coverage_item_Begin_Date_Time),
            ('Temporal_Coverage.Range_DateTime.Ending_Date_Time', self.checker_rules.check_Temporal_Coverage_item_end_Date_Time),
            ('Dataset_Progress', self.checker_rules.check_dataset_progress),
            ('Spatial_Coverage.Granule_Spatial_Representation', self.checker_rules.check_Spatial_Coverage_Granule_Spatial_Representation),
            ('Spatial_Coverage.Geometry.Coordinate_System', self.checker_rules.check_Spatial_Coverage_Geometry_Coordinate_System),
            ('Spatial_Coverage.Geometry.Bounding_Rectangle', self.checker_rules.check_Spatial_Coverage_Geometry_Bounding_Rectangle_Southernmost_Latitude),
            ('Spatial_Coverage.Geometry.Bounding_Rectangle', self.checker_rules.check_Spatial_Coverage_Geometry_Bounding_Rectangle_Northernmost_Latitude),
            ('Spatial_Coverage.Geometry.Bounding_Rectangle', self.checker_rules.check_Spatial_Coverage_Geometry_Bounding_Rectangle_Westernmost_Longitude),
            ('Spatial_Coverage.Geometry.Bounding_Rectangle', self.checker_rules.check_Spatial_Coverage_Geometry_Bounding_Rectangle_Easternmost_Longitude),
            ('Location.Location_Category', self.checker_rules.check_Location_Location_Category),
            ('Location.Location_Type', self.checker_rules.check_Location_Location_Type),
            ('Location.Location_Subregion1', self.checker_rules.check_Location_Subregion1),
            ('Location.Location_Subregion2', self.checker_rules.check_Location_Subregion2),
            ('Location.Location_Subregion3', self.checker_rules.check_Location_Subregion3),
            ('Data_Resolution.Horizontal_Resolution_Range', self.checker_rules.check_Horizontal_Resolution_Range),
            ('Data_Resolution.Vertical_Resolution_Range', self.checker_rules.check_Vertical_Resolution_Range),
            ('Data_Resolution.Temporal_Resolution_Range', self.checker_rules.check_Temporal_Resolution_Range),
            ('Project.Short_Name', self.checker_rules.check_Project_Short_Name),
            ('Project.Long_Name', self.checker_rules.check_Project_Long_Name),
            ('Quality', self.checker_rules.check_Quality),
            ('Dataset_Language', self.checker_rules.check_Dataset_Language),
            ('Organization.Organization_Type', self.checker_rules.check_Organization_Organization_Type),
            ('Organization.Organization_Name.Short_Name', self.checker_rules.check_Organization_Name_Short_Name),
            ('Organization.Organization_Name.Long_Name', self.checker_rules.check_Organization_Name_Long_Name),
            ('Organization.Personnel.Contact_Person.Phone.Type', self.checker_rules.check_Organization_Personnel_Contact_Person_Phone_Type),
            ('Organization.Personnel.Contact_Group.Phone.Type', self.checker_rules.check_Organization_Personnel_Contact_Person_Phone_Type),
            ('Distribution.Distribution_Format', self.checker_rules.check_Distribution_Distribution_Format),
            ('Multimedia_Sample.URL', self.checker_rules.check_Multimedia_Sample_URL),
            ('Summary.Abstract', self.checker_rules.check_summary_abstract),
            ('Related_URL.URL_Content_Type.Type', self.checker_rules.check_Related_URL_item_Content_Type),
            ('Related_URL.URL_Content_Type.Subtype', self.checker_rules.check_Related_URL_Content_Type_SubType),
            ('Related_URL.Description', self.checker_rules.check_Related_URL_Description_Item),
            ('Related_URL', self.checker_rules.check_Related_URL_Mime_Type),
            ('Product_Level_Id', self.checker_rules.check_Product_Level_ID),
            ('Collection_Data_Type', self.checker_rules.check_Collection_Data_Type),
            ('Metadata_Dates.Metadata_Creation', self.checker_rules.check_Metadata_Dates_Creation),
            ('Metadata_Dates.Metadata_Last_Revision', self.checker_rules.check_Metadata_last_revision),
            ('Metadata_Dates.Data_Creation', self.checker_rules.check_Metadata_data_creation),
            ('Metadata_Dates.Data_Last_Revision', self.checker_rules.check_Metadata_data_latest_revision),
        ]

        for key, check_function in checks:
            result[key] = self.safe_wrap(metadata, check_function, key)

        return result

    def safe_wrap(self, metadata, check_function, key):
        try:
            return self.wrap(metadata, check_function, key)
        except Exception:
            return 'np'
