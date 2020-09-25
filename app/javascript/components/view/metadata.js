const sample = {
  "DataLanguage": "eng",
  "AncillaryKeywords": ["Cloud Base Pressure", "Cloud Infrared Emissivity", "Cloud Layer Area", "Cloud Overlap", "Cloud Particle Phase", "Ice Particle Radius", "Ice Water Path", "Liquid Water Path", "Longwave (LW) Flux", "Shortwave (SW) Flux", "Surface (Radiative) Flux", "Surface Type", "TOA (Top of Atmosphere) Flux", "Visible Optical Depth", "Water Particle Radius", "Window (Wn) Flux"],
  "CollectionCitations": [{
    "OnlineResource": {
      "Linkage": "https://asdc.larc.nasa.gov/project/CERES"
    },
    "ReleaseDate": "2015-08-19T00:00:00.000Z"
  }],
  "SpatialExtent": {
    "SpatialCoverageType": "HORIZONTAL",
    "HorizontalSpatialDomain": {
      "Geometry": {
        "CoordinateSystem": "CARTESIAN",
        "BoundingRectangles": [{
          "WestBoundingCoordinate": -180.0,
          "NorthBoundingCoordinate": 90.0,
          "EastBoundingCoordinate": 180.0,
          "SouthBoundingCoordinate": -90.0
        }]
      },
      "ResolutionAndCoordinateSystem": {
        "HorizontalDataResolution": {
          "GenericResolutions": [{
            "Unit": "Not provided"
          }]
        }
      }
    },
    "GranuleSpatialRepresentation": "CARTESIAN"
  },
  "CollectionProgress": "ACTIVE",
  "ScienceKeywords": [{
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "ATMOSPHERIC RADIATION",
    "VariableLevel1": "OUTGOING LONGWAVE RADIATION"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "CLOUDS",
    "VariableLevel1": "CLOUD MICROPHYSICS",
    "VariableLevel2": "CLOUD LIQUID WATER/ICE"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "CLOUDS",
    "VariableLevel1": "CLOUD PROPERTIES",
    "VariableLevel2": "CLOUD TOP HEIGHT"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "ATMOSPHERIC RADIATION",
    "VariableLevel1": "RADIATIVE FLUX"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "CLOUDS",
    "VariableLevel1": "CLOUD PROPERTIES",
    "VariableLevel2": "CLOUD BASE PRESSURE"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "CLOUDS",
    "VariableLevel1": "CLOUD PROPERTIES",
    "VariableLevel2": "CLOUD TOP PRESSURE"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "ATMOSPHERIC TEMPERATURE",
    "VariableLevel1": "SURFACE TEMPERATURE",
    "VariableLevel2": "SKIN TEMPERATURE"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "CLOUDS",
    "VariableLevel1": "CLOUD MICROPHYSICS",
    "VariableLevel2": "CLOUD DROPLET CONCENTRATION/SIZE"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "ATMOSPHERIC RADIATION",
    "VariableLevel1": "ALBEDO"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "CLOUDS",
    "VariableLevel1": "CLOUD MICROPHYSICS",
    "VariableLevel2": "CLOUD OPTICAL DEPTH/THICKNESS"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "CLOUDS",
    "VariableLevel1": "CLOUD PROPERTIES",
    "VariableLevel2": "CLOUD TOP TEMPERATURE"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "ATMOSPHERIC RADIATION",
    "VariableLevel1": "NET RADIATION"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "CLOUDS",
    "VariableLevel1": "CLOUD PROPERTIES",
    "VariableLevel2": "CLOUD HEIGHT"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "CLOUDS",
    "VariableLevel1": "CLOUD RADIATIVE TRANSFER",
    "VariableLevel2": "CLOUD EMISSIVITY"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "CLOUDS",
    "VariableLevel1": "CLOUD PROPERTIES",
    "VariableLevel2": "CLOUD BASE TEMPERATURE"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "ATMOSPHERIC RADIATION",
    "VariableLevel1": "LONGWAVE RADIATION"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "ATMOSPHERIC RADIATION",
    "VariableLevel1": "INCOMING SOLAR RADIATION"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "ATMOSPHERIC RADIATION",
    "VariableLevel1": "SHORTWAVE RADIATION"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "ATMOSPHERIC WINDS",
    "VariableLevel1": "SURFACE WINDS",
    "VariableLevel2": "WIND SPEED"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "CLOUDS",
    "VariableLevel1": "CLOUD PROPERTIES",
    "VariableLevel2": "CLOUD FRACTION"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "ATMOSPHERIC PRESSURE",
    "VariableLevel1": "SURFACE PRESSURE"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "ATMOSPHERIC WATER VAPOR",
    "VariableLevel1": "WATER VAPOR INDICATORS",
    "VariableLevel2": "TOTAL PRECIPITABLE WATER"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "ATMOSPHERIC RADIATION",
    "VariableLevel1": "SOLAR IRRADIANCE"
  }, {
    "Category": "EARTH SCIENCE",
    "Topic": "ATMOSPHERE",
    "Term": "AEROSOLS",
    "VariableLevel1": "AEROSOL OPTICAL DEPTH/THICKNESS"
  }],
  "TemporalExtents": [{
    "EndsAtPresentFlag": true,
    "RangeDateTimes": [{
      "BeginningDateTime": "2002-07-01T00:00:00.000Z"
    }]
  }],
  "ProcessingLevel": {
    "Id": "3"
  },
  "DOI": {
    "DOI": "10.5067/AQUA/CERES/SSF1DEGDAY_L3.004A"
  },
  "ShortName": "CER_SSF1deg-Day_Aqua-MODIS",
  "EntryTitle": "CERES Time-Interpolated TOA Fluxes, Clouds and Aerosols Daily Aqua Edition4A",
  "ISOTopicCategories": ["CLIMATOLOGY/METEOROLOGY/ATMOSPHERE"],
  "AccessConstraints": {
    "Description": "No access constraints",
    "Value": 4.0
  },
  "RelatedUrls": [{
    "Description": "CERES project home page",
    "URLContentType": "CollectionURL",
    "Type": "PROJECT HOME PAGE",
    "URL": "https://ceres.larc.nasa.gov/"
  }, {
    "Description": "DOI data set landing page for CER_SSF1deg-Day_Aqua-MODIS_Edition4A",
    "URLContentType": "CollectionURL",
    "Type": "DATA SET LANDING PAGE",
    "URL": "https://doi.org/10.5067/AQUA/CERES/SSF1DEGDAY_L3.004A"
  }, {
    "Description": "Earthdata Search for CER_SSF1deg-Day_Aqua-MODIS_Edition4A (NASA Application to search, discover, visualize, refine, and access NASA Earth Observation data)",
    "URLContentType": "DistributionURL",
    "Type": "GET DATA",
    "Subtype": "Earthdata Search",
    "URL": "https://search.earthdata.nasa.gov/search/granules?p=C1000000600-LARC_ASDC"
  }, {
    "Description": "OPeNDAP data access for CER_SSF1deg-Day_Aqua-MODIS_Edition4A",
    "URLContentType": "DistributionURL",
    "Type": "USE SERVICE API",
    "Subtype": "OPENDAP DATA",
    "URL": "https://opendap.larc.nasa.gov/opendap/CERES/SSF1deg-Day/Aqua-MODIS_Edition4A/contents.html"
  }, {
    "Description": "How to cite ASDC data",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "DATA CITATION POLICY",
    "URL": "https://asdc.larc.nasa.gov/citing-data"
  }, {
    "Description": "Quality Summary: CERES_SSF1deg-Hour/Day/Month_Ed4A (3/13/2018)",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "DATA QUALITY",
    "URL": "https://ceres.larc.nasa.gov/documents/DQ_summaries/CERES_SSF1deg_Ed4A_DQS.pdf"
  }, {
    "Description": "ASDC Data and Information for CERES",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "GENERAL DOCUMENTATION",
    "URL": "https://asdc.larc.nasa.gov/project/CERES"
  }, {
    "Description": "CERES Data Products Catalog",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "PRODUCTION HISTORY",
    "URL": "https://asdc.larc.nasa.gov/documents/ceres/readme/ceres_data_products_catalogs.pdf"
  }, {
    "Description": "NASA Earthdata Forum - CERES",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "USER FEEDBACK PAGE",
    "URL": "https://forum.earthdata.nasa.gov/app.php/tag/CERES"
  }, {
    "Description": "CERES Instrument Working Group Web Sites",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "USER FEEDBACK PAGE",
    "URL": "https://ceres-instrument.larc.nasa.gov/"
  }, {
    "Description": "CERES Processing Level Details",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "PROCESSING HISTORY",
    "URL": "https://asdc.larc.nasa.gov/documents/ceres/level_table.pdf"
  }, {
    "Description": "CERES Product Level Details",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "PROCESSING HISTORY",
    "URL": "https://asdc.larc.nasa.gov/documents/ceres/product_level_details.pdf"
  }, {
    "Description": "NASA EOS ATB Documents: CERES",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "ALGORITHM THEORETICAL BASIS DOCUMENT (ATBD)",
    "URL": "https://eospso.gsfc.nasa.gov/atbd-category/40"
  }, {
    "Description": "ASDC Direct Data Download for CER_SSF1deg-Day_Aqua-MODIS_Edition4A",
    "URLContentType": "DistributionURL",
    "Type": "GET DATA",
    "Subtype": "DIRECT DOWNLOAD",
    "URL": "https://asdc.larc.nasa.gov/data/CERES/SSF1deg-Day/Aqua-MODIS_Edition4A/"
  }, {
    "Description": "NASA Earth Observatory Article: Aqua CERES First Light: Image of the Day - The Clouds and the Earth's Radiant Energy System (CERES) instrument is one of six on board the Aqua satellite.",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "PUBLICATIONS",
    "URL": "https://earthobservatory.nasa.gov/images/2654/aqua-ceres-first-light"
  }, {
    "Description": "NASA Earth Observatory Article: CERES Detects Earth's Heat and Energy: Image of the Day - Clouds and the Earth's Radiant Energy System (CERES) monitors solar energy reflected from the Earth and heat energy emitted from the Earth.",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "PUBLICATIONS",
    "URL": "https://earthobservatory.nasa.gov/images/563/ceres-detects-earths-heat-and-energy"
  }, {
    "Description": "NASA Earth Observatory Article: CERES Global Cloud Fraction - Each map combines observations from the CERES sensors on NASA's Terra and Aqua satellites collected on December 27, 2008",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "PUBLICATIONS",
    "URL": "https://earthobservatory.nasa.gov/images/36518/ceres-global-cloud-fraction"
  }, {
    "Description": "NASA Earth Observatory Article: First Monthly CERES Global Longwave and Shortwave Radiation - These measurements were acquired by NASA's Clouds and the Earth's Radiant Energy System (CERES) sensors during March 2000.",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "PUBLICATIONS",
    "URL": "https://earthobservatory.nasa.gov/images/600/first-monthly-ceres-global-longwave-and-shortwave-radiation"
  }, {
    "Description": "NASA Earth Observatory Article: Net Radiation - The measurements were made by the Clouds and the Earth's Radiant Energy System (CERES) sensors on NASA's Terra and Aqua satellites.",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "PUBLICATIONS",
    "URL": "https://earthobservatory.nasa.gov/global-maps/CERES_NETFLUX_M"
  }, {
    "Description": "NASA Earth Observatory Article: Space-based Observations of the Earth (Thermal radiation emitted from the Earth's surface and clouds on March 1, 2000 as seen by the Clouds and Earth's Radiant Energy System (CERES))",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "PUBLICATIONS",
    "URL": "https://earthobservatory.nasa.gov/features/Observing/obs_5.php"
  }, {
    "Description": "NASA Earth Observatory Article: The Arctic Is Absorbing More Sunlight - The radiation measurements were made by NASA's Clouds and the Earth's Radiant Energy System (CERES) instruments which fly on multiple satellites. ",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "PUBLICATIONS",
    "URL": "https://earthobservatory.nasa.gov/images/84930/the-arctic-is-absorbing-more-sunlight"
  }, {
    "Description": "NASA Earth Observatory Article: The Water Cycle - MODIS, CERES, and AIRS all collect data relevant to the study of clouds.",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "PUBLICATIONS",
    "URL": "https://earthobservatory.nasa.gov/features/Water/page4.php"
  }, {
    "Description": "NASA Earth Observatory Article: Tropical Cloud Systems and CERES: Image of the Day - CERES detects the amount of outgoing heat and reflected sunlight leaving the planet.",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "PUBLICATIONS",
    "URL": "https://earthobservatory.nasa.gov/images/2984/tropical-cloud-systems-and-ceres"
  }, {
    "Description": "Overview of HDF",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "GENERAL DOCUMENTATION",
    "URL": "https://asdc.larc.nasa.gov/documents/tools/hdf.pdf"
  }, {
    "Description": "Overview of view hdf: A Visualization and Analysis Tool for HDF Files",
    "URLContentType": "DistributionURL",
    "Type": "GOTO WEB TOOL",
    "Subtype": "MAP VIEWER",
    "URL": "https://asdc.larc.nasa.gov/documents/tools/view_hdf.pdf"
  }, {
    "Description": "ASDC List of CERES Examples: Spatial Extent and Scan Modes",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "GENERAL DOCUMENTATION",
    "URL": "https://asdc.larc.nasa.gov/documents/ceres/examples.html"
  }, {
    "Description": "CERES Data Products Browse, Subset, and Order",
    "URLContentType": "DistributionURL",
    "Type": "GOTO WEB TOOL",
    "Subtype": "SUBSETTER",
    "URL": "https://ceres.larc.nasa.gov/data/"
  }, {
    "Description": "CERES Data Products Browse, Subset, and Order: Single Scanner Footprint (SSF)",
    "URLContentType": "DistributionURL",
    "Type": "GOTO WEB TOOL",
    "Subtype": "SUBSETTER",
    "URL": "https://ceres.larc.nasa.gov/data/#single-scanner-footprint-ssf"
  }, {
    "Description": "CERES Documentation",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "GENERAL DOCUMENTATION",
    "URL": "https://ceres.larc.nasa.gov/data/documentation/"
  }, {
    "Description": "CERES Documentation: Data Products Catalog",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "PRODUCTION HISTORY",
    "URL": "https://ceres.larc.nasa.gov/data/documentation/#data-products-catalog"
  }, {
    "Description": "CERES General Product Info",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "GENERAL DOCUMENTATION",
    "URL": "https://ceres.larc.nasa.gov/data/general-product-info/"
  }, {
    "Description": "CERES Input Data Sources",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "REQUIREMENTS AND DESIGN",
    "URL": "https://ceres.larc.nasa.gov/data/general-product-info/#ceres-input-data-sources"
  }, {
    "Description": "CERES Overview of Aqua",
    "URLContentType": "PublicationURL",
    "Type": "VIEW RELATED INFORMATION",
    "Subtype": "GENERAL DOCUMENTATION",
    "URL": "https://ceres.larc.nasa.gov/instruments/satellite-missions/#aqua"
  }],
  "DataDates": [{
    "Date": "2015-02-23T00:00:00.000Z",
    "Type": "CREATE"
  }, {
    "Date": "2018-07-13T00:00:00.000Z",
    "Type": "UPDATE"
  }],
  "Abstract": "CER_SSF1deg-Day_Aqua-MODIS_Edition4A is the Clouds and the Earth's Radiant Energy System (CERES) Time-Interpolated Top of Atmosphere (TOA) Fluxes, Clouds and Aerosols Daily Aqua Edition4A data product, which was collected using the CERES-Flight Model 3 (FM3) and FM4 instruments on the Aqua platform. Data collection for this product is in progress.\r\rCERES Single Scanner Footprint one degree (SSF1deg) Day provides daily averages of regional constant meteorology temporally interpolated TOA fluxes, clouds derived from a co-located imager and aerosols on a 1-degree latitude and longitude grid. This is a single satellite product that uses the primary CERES instrument in cross-track mode. TOA fluxes are provided for clear-sky and all-sky conditions for longwave (LW), shortwave (SW), and window (WN) wavelength bands. The incoming solar daily irradiance is from the SOlar Radiation and Climate Experiment (SORCE) and Total Solar Irradiance (TSI). The cloud properties are averaged for both day and night (24-hour) and day-only time periods. Cloud properties are stratified into 4 atmospheric layers (surface-700 hPa, 700 hPa - 500 hPa, 500 hPa - 300 hPa, 300 hPa - 100 hPa) and a total of all layers. The aerosols are averaged instantaneous values from the co-located imager. \r\rCERES is a key component of the Earth Observing System (EOS) program. The CERES instruments provide radiometric measurements of the Earth's atmosphere from three broadband channels. The CERES missions are a follow-on to the successful Earth Radiation Budget Experiment (ERBE) mission. The first CERES instrument, protoflight model (PFM), was launched on November 27, 1997 as part of the Tropical Rainfall Measuring Mission (TRMM). Two CERES instruments (FM1 and FM2) were launched into polar orbit on board the Earth Observing System (EOS) flagship Terra on December 18, 1999. Two additional CERES instruments (FM3 and FM4) were launched on board Earth Observing System (EOS) Aqua on May 4, 2002. The CERES FM5 instrument was launched on board the Suomi National Polar-orbiting Partnership (NPP) satellite on October 28, 2011. The newest CERES instrument (FM6) was launched on board the Joint Polar-Orbiting Satellite System 1 (JPSS-1) satellite, now called NOAA-20, on November 18, 2017.",
  "LocationKeywords": [{
    "Category": "GEOGRAPHIC REGION",
    "Type": "GLOBAL"
  }],
  "MetadataDates": [{
    "Date": "2015-02-23T00:00:00.000Z",
    "Type": "CREATE"
  }, {
    "Date": "2020-08-17T00:00:00.000Z",
    "Type": "UPDATE"
  }],
  "MetadataAssociations": [{
    "Type": "PARENT",
    "Description": "Preceding version",
    "EntryId": "CER_SSF1deg-Day_Aqua-MODIS",
    "Version": "Edition3A"
  }],
  "VersionDescription": "SSF1deg-Day Edition4A leverages algorithm changes to inputs include improved instrument  calibration, cloud properties, and Angular Distribution Models (ADMs).  A consistent meteorological assimilation data (GEOS 5.4.1) and MODIS radiances and aerosols are  based upon Collection5 through January 2017 before changing to Collection 6.Not provided",
  "Version": "Edition4A",
  "Projects": [{
    "ShortName": "CERES",
    "LongName": "Clouds and the Earth's Radiant Energy System"
  }],
  "ContactPersons": [{
    "Roles": ["Technical Contact"],
    "ContactInformation": {
      "ContactMechanisms": [{
        "Type": "Email",
        "Value": "david.r.doelling@nasa.gov"
      }],
      "Addresses": [{
        "StreetAddresses": ["Mail Stop 420\r", "Atmospheric Sciences Research, Building 1250\r", "21 Langley Boulevard\r", "NASA Langley Research Center"],
        "City": "Hampton",
        "StateProvince": "VA",
        "Country": "United States",
        "PostalCode": "23681-2199"
      }]
    },
    "FirstName": "DAVID",
    "MiddleName": "R.",
    "LastName": "DOELLING"
  }, {
    "Roles": ["Investigator"],
    "ContactInformation": {
      "ContactMechanisms": [{
        "Type": "Email",
        "Value": "ceres-help@lists.nasa.gov"
      }],
      "Addresses": [{
        "City": "Hampton",
        "StateProvince": "VA",
        "Country": "United States",
        "PostalCode": "23681-2199"
      }]
    },
    "FirstName": "NORMAN",
    "MiddleName": "G.",
    "LastName": "LOEB"
  }],
  "DataCenters": [{
    "Roles": ["ARCHIVER"],
    "ShortName": "NASA/LARC/SD/ASDC",
    "LongName": "Atmospheric Science Data Center, Science Directorate, Langley Research Center, NASA",
    "ContactGroups": [{
      "Roles": ["Data Center Contact"],
      "ContactInformation": {
        "ContactMechanisms": [{
          "Type": "Email",
          "Value": "support-asdc@earthdata.nasa.gov"
        }, {
          "Type": "Telephone",
          "Value": "757-864-8656"
        }],
        "Addresses": [{
          "StreetAddresses": ["NASA Langley Atmospheric Science Data Center\r", "User and Data Services\r", "NASA Langley Research Center\r", "Mail Stop 157D"],
          "City": "Hampton",
          "StateProvince": "VA",
          "Country": "USA",
          "PostalCode": "23681-2199"
        }]
      },
      "GroupName": "ASDC USER SERVICES"
    }],
    "ContactInformation": {
      "RelatedUrls": [{
        "URLContentType": "DataCenterURL",
        "Type": "HOME PAGE",
        "URL": "https://asdc.larc.nasa.gov"
      }]
    }
  }],
  "TemporalKeywords": ["Daily"],
  "Platforms": [{
    "Type": "Earth Observation Satellites",
    "ShortName": "AQUA",
    "LongName": "Earth Observing System, AQUA",
    "Instruments": [{
      "ShortName": "CERES-FM4",
      "LongName": "Clouds and the Earth's Radiant Energy System - Flight Model 4",
      "ComposedOf": [{
        "ShortName": "Radiometer"
      }]
    }, {
      "ShortName": "CERES-FM3",
      "LongName": "Clouds and the Earth's Radiant Energy System - Flight Model 3",
      "ComposedOf": [{
        "ShortName": "Radiometer"
      }]
    }]
  }],
  "ArchiveAndDistributionInformation": {
    "FileDistributionInformation": [{
      "FormatType": "Native",
      "Fees": "none",
      "Format": "HDF4",
      "Media": ["Online"]
    }]
  }
}
export default sample