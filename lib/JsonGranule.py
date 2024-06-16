"""
This file is for generating CSV output for Collection DIF data.
"""

class GranuleOutputJSON:
    def __init__(self, checker_rules, fetch_all_instrs):
        self.checker_rules = checker_rules
        self.fetch_all_instrs = fetch_all_instrs

    def check_all(self, metadata):
        result = {}
        checks = [
            ('InsertTime', self.checker_rules.checkInsertTime),
            ('LastUpdate', lambda md: self.checker_rules.checkLastUpdate(md['LastUpdate'], md['DataGranule']['ProductionDateTime'])),
            ('DeleteTime', lambda md: self.checker_rules.checkDeleteTime(md['DeleteTime'], md['DataGranule']['ProductionDateTime'])),
            ('Collection/ShortName', self.checker_rules.checkCollectionShortName, KeyError, "np - Ensure the DataSetId field is provided."),
            ('Collection/VersionId', self.checker_rules.checkCollectionVersionID, KeyError, "np - Ensure the DataSetId field is provided."),
            ('Collection/DataSetId', self.checker_rules.checkDataSetId, KeyError, "np - Ensure that the ShortName and VersionId fields are provided."),
            ('DataGranule/SizeMBDataGranule', self.checker_rules.checkSizeMBDataGranule, KeyError, "Granule file size not provided. Recommend providing a value for this field in the metadata"),
            ('DataGranule/DayNightFlag', self.checker_rules.checkDayNightFlag),
            ('DataGranule/ProductionDateTime', lambda md: self.checker_rules.checkProductionDateTime(md['DataGranule']['ProductionDateTime'], md['InsertTime'])),
            ('Temporal/RangeDateTime/SingleDateTime', self.checker_rules.checkTemporalSingleTime),
            ('Temporal/RangeDateTime/BeginningDateTime', self.checker_rules.checkTemporalBeginningTime),
            ('Temporal/RangeDateTime/EndingDateTime', self.checker_rules.checkTemporalEndingTime, KeyError, "np"),
            ('Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle', self.checker_rules.checkBoundingRectangle, None, "np, np, np, np"),
            ('OrbitCalculatedSpatialDomains/OrbitCalculatedSpatialDomain/EquatorCrossingDateTime', self.checker_rules.checkEquatorCrossingTime, TypeError, "np", self.check_equator_crossing_time),
            ('Platforms/Platform/ShortName', self.checker_rules.checkPlatformShortName, TypeError, "np", self.check_platform_short_name),
            ('Platforms/Platform/Instruments/Instrument/ShortName', self.check_instruments_short_name),
            ('Platforms/Platform/Instruments/Instrument/Sensors/Sensor/ShortName', self.check_sensor_short_name),
            ('Campaigns/', self.check_campaign_short_name),
            ('OnlineAccessURLs/OnlineAccessURL/URL', self.check_online_access_url, TypeError, "No Online Access URL is provided"),
            ('OnlineAccessURLs/OnlineAccessURL/URLDescription', self.check_online_access_url_desc, TypeError, "Recommend providing a brief URL description"),
            ('OnlineResources/OnlineResource/URL', self.check_online_resource_url),
            ('OnlineResource/OnlineResource/Description', self.check_online_resource_desc),
            ('OnlineResources/OnlineResource/Type', self.check_online_resource_type),
            ('Orderable', self.checker_rules.checkOrderable),
            ('DataFormat', self.checker_rules.checkDataFormat, KeyError, "Recommend providing the data format for the associated granule"),
            ('Visible', self.checker_rules.checkVisible),
        ]

        for key, check_function, *exception_handling in checks:
            result[key] = self.safe_wrap(metadata, key, check_function, *exception_handling)

        return result

    def safe_wrap(self, metadata, key, check_function, specific_exception=None, specific_message=None, alternative_function=None):
        try:
            if alternative_function:
                return alternative_function(metadata, check_function)
            return check_function(metadata[key])
        except specific_exception:
            return specific_message
        except Exception:
            return "np"

    def check_equator_crossing_time(self, metadata, check_function):
        try:
            return check_function(metadata['OrbitCalculatedSpatialDomains']['OrbitCalculatedSpatialDomain']['EquatorCrossingDateTime'], 1)
        except TypeError:
            if metadata['OrbitCalculatedSpatialDomains'] and metadata['OrbitCalculatedSpatialDomains']['OrbitCalculatedSpatialDomain']:
                length = len(metadata['OrbitCalculatedSpatialDomains']['OrbitCalculatedSpatialDomain'])
                try:
                    return check_function(metadata['OrbitCalculatedSpatialDomains']['OrbitCalculatedSpatialDomain']['EquatorCrossingDateTime'], length)
                except:
                    return "np"
            return "np"

    def check_platform_short_name(self, metadata, check_function):
        try:
            return check_function(metadata['Platforms']['Platform']['ShortName'], 1)
        except TypeError:
            if metadata['Platforms'] and metadata['Platforms']['Platform']:
                length = len(metadata['Platforms']['Platform'])
                return check_function(metadata['Platforms']['Platform'], length)
            return "np"

    def check_instruments_short_name(self, metadata, check_function):
        sensor_short_result = ''
        try:
            metadata['Platforms']['Platform']['ShortName']
            platform_num = 1
            ret, sensor_short_result = check_function(metadata['Platforms']['Platform'], platform_num, self.fetch_all_instrs)
            return ret
        except TypeError:
            if metadata['Platforms'] and metadata['Platforms']['Platform']:
                platform_num = len(metadata['Platforms']['Platform'])
                ret, sensor_short_result = check_function(metadata['Platforms']['Platform'], platform_num, self.fetch_all_instrs)
                return ret
            return 'np'

    def check_sensor_short_name(self, metadata, check_function):
        sensor_short_result = self.check_instruments_short_name(metadata, check_function)
        if len(sensor_short_result) == 0:
            return 'np'
        return sensor_short_result

    def check_campaign_short_name(self, metadata, check_function):
        try:
            campaign_num = 1
            return check_function(metadata['Campaigns']['Campaign']['ShortName'], campaign_num)
        except TypeError:
            if metadata['Campaigns'] and metadata['Campaigns']['Campaign']:
                campaign_num = len(metadata['Campaigns'])
                return check_function(metadata['Campaigns'], campaign_num)
        except:
            return "np"

    def check_online_access_url(self, metadata, check_function):
        try:
            return check_function(metadata['OnlineAccessURLs']['OnlineAccessURL']['URL'], 1)
        except TypeError:
            if metadata['OnlineAccessURLs']:
                length = len(metadata['OnlineAccessURLs']['OnlineAccessURL'])
                return check_function(metadata['OnlineAccessURLs']['OnlineAccessURL'], length)
        except KeyError:
            return "No Online Access URL is provided"
        except:
            return "np"

    def check_online_access_url_desc(self, metadata, check_function):
        try:
            return check_function(metadata['OnlineAccessURLs']['OnlineAccessURL']['URLDescription'], 1)
        except TypeError:
            if metadata['OnlineAccessURLs']:
                length = len(metadata['OnlineAccessURLs']['OnlineAccessURL'])
                return check_function(metadata['OnlineAccessURLs']['OnlineAccessURL'], length)
        except KeyError:
            return "Recommend providing a brief URL description"
        except:
            return "np"

    def check_online_resource_url(self, metadata, check_function):
        try:
            return check_function(metadata['OnlineResources']['OnlineResource']['URL'], 1)
        except TypeError:
            if metadata['OnlineResources']:
                length = len(metadata['OnlineResources']['OnlineResource'])
                return check_function(metadata['OnlineResources']['OnlineResource'], length)
        except:
            return "np"

    def check_online_resource_desc(self, metadata, check_function):
        try:
            return check_function(metadata['OnlineResources']['OnlineResource']['Description'], 1)
        except TypeError:
            if metadata['OnlineResources']:
                length = len(metadata['OnlineResources']['OnlineResource'])
                return check_function(metadata['OnlineResources']['OnlineResource'], length)
        except:
            return "np"

    def check_online_resource_type(self, metadata, check_function):
        try:
            return check_function(metadata['OnlineResources']['OnlineResource']['Type'], 1)
        except TypeError:
            if metadata['OnlineResources']:
                length = len(metadata['OnlineResources']['OnlineResource'])
                return check_function(metadata['OnlineResources']['OnlineResource'], length)
        except:
            return "np"
