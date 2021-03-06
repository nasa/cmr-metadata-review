module RecordFormats
  module Dif10Fields
     SECTION_TITLES = [
      "Summary",
      "Platform",
      "Science_Keywords",
      "Platform",
      "Dataset_Citation",
      "Organization",
      "Personnel",
      "Reference",
      "Location",
      "Data_Resolution",
      "Related_URL",
      "Distribution",
      "Multimedia_Sample",
      "Additional_Attributes",
      "Temporal_Coverage",
      "Spatial_Coverage",
      "Project",
      "Metadata_Dates",
      "Metadata_Association",
      "IDN_Node",
      "Extended_Metadata"
    ]

    REQUIRED_COLLECTION_FIELDS = [
      "Entry_ID/Short_Name",
      "Entry_ID/Version",
      "Entry_Title",
      "Science_Keywords/Category",
      "Science_Keywords/Topic",
      "Science_Keywords/Term",
      "Platform/Short_Name",
      "Platform/Instrument/Short_Name",
      "Temporal_Coverage/Range_DateTime/Beginning_Date_Time",
      "Temporal_Coverage/Range_DateTime/Ending_Date_Time",
      "Temporal_Coverage/Single_Date_Time",
      "Temporal_Coverage/Periodic_DateTime/Name",
      "Temporal_Coverage/Periodic_DateTime/Start_Date",
      "Temporal_Coverage/Periodic_DateTime/End_Date",
      "Temporal_Coverage/Periodic_DateTime/Duration_Unit",
      "Temporal_Coverage/Periodic_DateTime/Duration_Value",
      "Temporal_Coverage/Periodic_DateTime/Period_Cycle_Duration_Unit",
      "Temporal_Coverage/Periodic_DateTime/Period_Cycle_Duration_Value",
      "Temporal_Coverage/Paleo_DateTime/Paleo_Start_Date",
      "Temporal_Coverage/Paleo_DateTime/Paleo_Stop_Date",
      "Dataset_Progress",
      "Spatial_Coverage/Granule_Spatial_Representation",
      "Spatial_Coverage/Geometry/Coordinate_System",
      "Spatial_Coverage/Geometry/Bounding_Rectangle/Southernmost_Latitude",
      "Spatial_Coverage/Geometry/Bounding_Rectangle/Northernmost_Latitude",
      "Spatial_Coverage/Geometry/Bounding_Rectangle/Westernmost_Longitude",
      "Spatial_Coverage/Geometry/Bounding_Rectangle/Easternmost_Longitude",
      "Spatial_Coverage/Geometry/Point/Point_Longitude",
      "Spatial_Coverage/Geometry/Point/Point_Latitude",
      "Spatial_Coverage/Geometry/Line/Point/Point_Longitude",
      "Spatial_Coverage/Geometry/Line/Point/Point_Latitude",
      "Spatial_Coverage/Geometry/Polygon/Boundary/Point/Point_Longitude",
      "Spatial_Coverage/Geometry/Polygon/Boundary/Point/Point_Latitude",
      "Organization/Organization_Type",
      "Organization/Organization_Name/Short_Name",
      "Summary/Abstract",
      "Related_URL/URL_Content_Type/Type",
      "Related_URL/URL",
      "Product_Level_Id",
      "Metadata_Dates/Metadata_Creation",
      "Metadata_Dates/Metadata_Last_Revision",
      "Metadata_Dates/Data_Creation",
      "Metadata_Dates/Data_Last_Revision",
      "Dataset_Citation/Persistent_Identifier/Type",
      "Dataset_Citation/Persistent_Identifier/Identifier"
    ]

    DESIRED_FIELDS = [
      "Entry_ID/Short_Name",
      "Entry_ID/Version",
      "Entry_Title",
      "Dataset_Citation/Persistent_Identifier/Type",
      "Dataset_Citation/Persistent_Identifier/Identifier",
      "Personnel/Contact_Group/Name",
      "Science_Keywords/Category",
      "Science_Keywords/Topic",
      "Science_Keywords/Term",
      "Science_Keywords/Variable_Level_1",
      "Science_Keywords/Variable_Level_2",
      "Science_Keywords/Variable_Level_3",
      "Science_Keywords/Detailed_Variable",
      "Platform/Type",
      "Platform/Short_Name",
      "Platform/Long_Name",
      "Platform/Instrument/Short_Name",
      "Platform/Instrument/Long_Name",
      "Platform/Instrument/Sensor/Short_Name",
      "Platform/Instrument/Sensor/Long_Name",
      "Temporal_Coverage/Ends_At_Present_Flag",
      "Temporal_Coverage/Range_DateTime/Beginning_Date_Time",
      "Temporal_Coverage/Range_DateTime/Ending_Date_Time",
      "Temporal_Coverage/Single_Date_Time",
      "Dataset_Progress",
      "Spatial_Coverage/Granule_Spatial_Representation",
      "Spatial_Coverage/Geometry/Coordinate_System",
      "Spatial_Coverage/Geometry/Bounding_Rectangle/Center_Point/Point/Point_Longitude",
      "Spatial_Coverage/Geometry/Bounding_Rectangle/Center_Point/Point/Point_Latitude",
      "Spatial_Coverage/Geometry/Bounding_Rectangle/Southernmost_Latitude",
      "Spatial_Coverage/Geometry/Bounding_Rectangle/Northernmost_Latitude",
      "Spatial_Coverage/Geometry/Bounding_Rectangle/Westernmost_Longitude",
      "Spatial_Coverage/Geometry/Bounding_Rectangle/Easternmost_Longitude",
      "Spatial_Coverage/Geometry/Bounding_Rectangle/Minimum_Altitude",
      "Spatial_Coverage/Spatial_Info/Spatial_Coverage_Type",
      "Spatial_Coverage/Spatial_Info/Horizontal_Coordinate_System/Geodetic_Model/Horizontal_DatumName",
      "Spatial_Coverage/Spatial_Info/Horizontal_Coordinate_System/Geodetic_Model/Ellipsoid_Name",
      "Spatial_Coverage/Spatial_Info/Horizontal_Coordinate_System/Geodetic_Model/Semi_Major_Axis",
      "Spatial_Coverage/Spatial_Info/Horizontal_Coordinate_System/Geodetic_Model/Denominator_Of_Flattening_Ratio",
      "Spatial_Coverage/Spatial_Info/Horizontal_Coordinate_System/Geographic_Coordinate_System/GeographicCoordinateUnits",
      "Spatial_Coverage/Spatial_Info/Horizontal_Coordinate_System/Geographic_Coordinate_System/LatitudeResolution",
      "Spatial_Coverage/Spatial_Info/Horizontal_Coordinate_System/Geographic_Coordinate_System/LongitudeResolution",
      "Location/Location_Category",
      "Data_Resolution/Latitude_Resolution",
      "Data_Resolution/Longitude_Resolution",
      "Data_Resolution/Horizontal_Resolution_Range",
      "Data_Resolution/Vertical_Resolution",
      "Data_Resolution/Vertical_Resolution_Unit",
      "Data_Resolution/Vertical_Resolution_Range",
      "Data_Resolution/Temporal_Resolution",
      "Data_Resolution/Temporal_Resolution_Range",
      "Project/Short_Name",
      "Project/Long_Name",
      "Organization/Organization_Type",
      "Organization/Organization_Name/Short_Name",
      "Organization/Organization_Name/Long_Name",
      "Organization/Organization_URL",
      "Organization/Personnel/Contact_Group/Name",
      "Distribution/Distribution_Format",
      "Multimedia_Sample/URL",
      "Multimedia_Sample/Description",
      "Reference/Citation",
      "Summary/Abstract",
      "Related_URL/URL_Content_Type/Type",
      "Related_URL/URL_Content_Type/Subtype",
      "Related_URL/URL",
      "Related_URL/Description",
      "Related_URL/Mime_Type",
      "Product_Level_Id",
      "Collection_Data_Type",
      "Metadata_Dates/Metadata_Creation",
      "Metadata_Dates/Metadata_Last_Revision",
      "Metadata_Dates/Data_Creation",
      "Metadata_Dates/Data_Last_Revision"
    ]
  end
end
