'''This file is for get CSV output for Collection DIF data'''

class GranuleOutputJSON():
    def __init__(self,checkerRules,fetchAllInstrs):
        self.checkerRules = checkerRules
        self.fetchAllInstrs = fetchAllInstrs

    def checkAll(self, metadata):
        result = {}
        # ================
        str = 'InsertTime'
        try:
            result[str] = self.checkerRules.checkInsertTime(metadata[str])
        except:
            result[str] = "np"
        # ================
        str = 'LastUpdate'
        try:
            result[str] = self.checkerRules.checkLastUpdate(metadata['LastUpdate'],metadata['DataGranule']['ProductionDateTime'])
        except:
            result[str] = "np"
        # ================
        str = 'DeleteTime'
        try:
            result[str] = self.checkerRules.checkDeleteTime(metadata['DeleteTime'],
                                                        metadata['DataGranule']['ProductionDateTime'])
        except:
            result[str] = "np"
        # ================
        str = 'Collection/ShortName'
        try:
            result[str] = self.checkerRules.checkCollectionShortName(metadata['Collection']['ShortName'])
        except KeyError:
            result[str] = "np - Ensure the DataSetId field is provided."
        except:
            result[str] = "np"
        # =================
        str = 'Collection/VersionId'
        try:
            result[str] = self.checkerRules.checkCollectionVersionID(metadata['Collection']['VersionId'])
        except KeyError:
            result[str] = "np - Ensure the DataSetId field is provided."
        except:
            result[str] = "np"
        # ================
        str = 'Collection/DataSetId'
        try:
            result[str] = self.checkerRules.checkDataSetId(metadata['Collection']['DataSetId'])
        except KeyError:
            result[str] = "np - Ensure that the ShortName and VersionId fields are provided."
        except:
            result[str] = "np"
        # ================
        str = 'DataGranule/SizeMBDataGranule'
        try:
            result[str] = self.checkerRules.checkSizeMBDataGranule(
                metadata['DataGranule']['SizeMBDataGranule'])
        except KeyError:
            result[str] = "Granule file size not provided. Recommend providing a value for this field in the metadata"
        except:
            result[str] = "np"
        # ================
        str = 'DataGranule/DayNightFlag'
        try:
            result[str] = self.checkerRules.checkDayNightFlag(metadata['DataGranule']['DayNightFlag'])
        except:
            result[str] = "np"
        # ================
        str = 'DataGranule/ProductionDateTime'
        try:
            result[str] = self.checkerRules.checkProductionDateTime(metadata['DataGranule']['ProductionDateTime'],metadata['InsertTime'])
        except:
            result[str] = "np"
        # ================
        str = 'Temporal/RangeDateTime/SingleDateTime'
        try:
            result[str] = self.checkerRules.checkTemporalSingleTime(metadata['Temporal']['RangeDateTime']['SingleDateTime'])
        except:
            result[str] = "np"
        # ================
        str = 'Temporal/RangeDateTime/BeginningDateTime'
        try:
            result[str] = self.checkerRules.checkTemporalBeginningTime(metadata['Temporal']['RangeDateTime']['BeginningDateTime'])
        except:
            result[str] = "np"
        # ================
        str = 'Temporal/RangeDateTime/EndingDateTime'
        try:
            result[str] = self.checkerRules.checkTemporalEndingTime(metadata['Temporal']['RangeDateTime']['EndingDateTime'])
        except KeyError:
            result[str] = "np"
        # ================
        str = 'Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle'
        try:
            result[str] = self.checkerRules.checkBoundingRectangle(
                metadata['Spatial']['HorizontalSpatialDomain']['Geometry'][
                    'BoundingRectangle'])
        except:
            result[str] = "np, np, np, np"
        # ================
        str = 'OrbitCalculatedSpatialDomains/OrbitCalculatedSpatialDomain/EquatorCrossingDateTime'
        try:
            result[str] = self.checkerRules.checkEquatorCrossingTime(
                metadata['OrbitCalculatedSpatialDomains']['OrbitCalculatedSpatialDomain'][
                    'EquatorCrossingDateTime'], 1)
        except TypeError:
            if metadata['OrbitCalculatedSpatialDomains'] != None and metadata['OrbitCalculatedSpatialDomains'][
                'OrbitCalculatedSpatialDomain'] != None:
                length = len(metadata['OrbitCalculatedSpatialDomains']['OrbitCalculatedSpatialDomain'])
                try:
                  result[str] = self.checkerRules.checkEquatorCrossingTime(
                      metadata['OrbitCalculatedSpatialDomains']['OrbitCalculatedSpatialDomain'][
                          'EquatorCrossingDateTime'], length)
                except:
                  result[str]= "np"
            else:
                result[str] = "np"
        except:
            result[str]= "np"
        # ================
        str = 'Platforms/Platform/ShortName'
        try:
            result[str] = self.checkerRules.checkPlatformShortName(metadata['Platforms']['Platform']['ShortName'],1)
        except TypeError:
            if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                length = len(metadata['Platforms']['Platform'])
                result[str] = self.checkerRules.checkPlatformShortName(metadata['Platforms']['Platform'], length)
            else:
                result[str] = "np"
        except:
            result[str] = "np"
        # ================
        # try:
        #     metadata['Platforms']['Platform']['ShortName']
        #     platform_num = 1
        #     result += self.checkInstrShortName(metadata['Platforms']['Platform'], platform_num) + ', , , '
        # except TypeError:
        #     if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
        #         platform_num = len(metadata['Platforms']['Platform'])
        #         result += self.checkInstrShortName(metadata['Platforms']['Platform'], platform_num) + ', , , '
        #     else:
        #         result += "np" + ', , , '
        # except KeyError:
        #     result += "np" + ', , , '
        # ================
        str = 'Platforms/Platform/Instruments/Instrument/ShortName'
        instruments = self.fetchAllInstrs
        sensorShortResult = ''
        try:
            metadata['Platforms']['Platform']['ShortName']
            platform_num = 1
            ret, sensorShortResult = self.checkerRules.checkInstrShortName(metadata['Platforms']['Platform'],
                                                                           platform_num, instruments)
            result[str] = ret
        except TypeError:
            if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                platform_num = len(metadata['Platforms']['Platform'])
                ret, sensorShortResult = self.checkerRules.checkInstrShortName(metadata['Platforms']['Platform'],
                                                                               platform_num, instruments)
                result[str] = ret
            else:
                result[str] = 'np'
        except KeyError:
            result[str] = 'np'
        # ================
        str = 'Platforms/Platform/Instruments/Instrument/Sensors/Sensor/ShortName'
        if len(sensorShortResult) == 0:
            result[str] = 'np'
        else:
            result[str] = sensorShortResult
        # ================
        str = 'Campaigns/'
        try:
            campaign_num = 1
            result[str] = self.checkerRules.checkCampaignShortName(metadata['Campaigns']['Campaign']['ShortName'],campaign_num)
        except TypeError:
            if metadata['Campaigns'] != None and metadata['Campaigns']['Campaign'] != None:
                campaign_num = len(metadata['Campaigns'])
                result[str] = self.checkerRules.checkCampaignShortName(metadata['Campaigns'],campaign_num)
        except:
            result[str] = "np"
        # ================
        str = 'OnlineAccessURLs/OnlineAccessURL/URL'
        try:
            result[str] = self.checkerRules.checkOnlineAccessURL(metadata['OnlineAccessURLs']['OnlineAccessURL']['URL'],1)
        except TypeError:
            if metadata['OnlineAccessURLs'] != None:
                length = len(metadata['OnlineAccessURLs']['OnlineAccessURL'])
                result[str] = self.checkerRules.checkOnlineAccessURL(metadata['OnlineAccessURLs']['OnlineAccessURL'],
                                                                 length)
            else:
                result[str] = "No Online Access URL is provided"
        except KeyError:
            result[str] = "No Online Access URL is provided"
        except:
            result[str] = "np"
        # ================
        str = 'OnlineAccessURLs/OnlineAccessURL/URLDescription'
        try:
            result[str]= self.checkerRules.checkOnlineAccessURLDesc(
                metadata['OnlineAccessURLs']['OnlineAccessURL']['URLDescription'], 1)
        except TypeError:
            if metadata['OnlineAccessURLs'] != None:
                length = len(metadata['OnlineAccessURLs']['OnlineAccessURL'])
                result[str] = self.checkerRules.checkOnlineAccessURLDesc(metadata['OnlineAccessURLs']['OnlineAccessURL'], length)
            else:
                result[str] = "Recommend providing a brief URL description"
        except KeyError:
            result[str] = "Recommend providing a brief URL description"
        except:
            result[str] = "np"
        # ================
        str = 'OnlineResources/OnlineResource/URL'
        OnlineResourceURL_Cnt = 0
        try:
            result[str] = self.checkerRules.checkOnlineResourceURL(metadata['OnlineResources']['OnlineResource']['URL'],
                                                               1)
            OnlineResourceURL_Cnt = 1
        except TypeError:
            if metadata['OnlineResources'] != None:
                length = len(metadata['OnlineResources']['OnlineResource'])
                OnlineResourceURL_Cnt = length
                result[str] = self.checkerRules.checkOnlineResourceURL(metadata['OnlineResources']['OnlineResource'],
                                                                   length)
            else:
                result[str] = "np"
        except:
            result[str] = "np"
        # ================
        str = 'OnlineResource/OnlineResource/Description'
        try:
            result[str] = self.checkerRules.checkOnlineResourceDesc(
                metadata['OnlineResources']['OnlineResource']['Description'], 1)
        except TypeError:
            if metadata['OnlineResources'] != None:
                length = len(metadata['OnlineResources']['OnlineResource'])
                if length < OnlineResourceURL_Cnt:
                    result[str] = "Recommend providing descriptions for all Online Resource URLs."
                else:
                    result[str] = self.checkerRules.checkOnlineResourceDesc(
                        metadata['OnlineResources']['OnlineResource'], length)
            else:
                result[str] = "np"
        except:
            result[str] = "np"
        # ================
        str = 'OnlineResources/OnlineResource/Type'
        try:
            result[str] = self.checkerRules.checkOnlineResourceType(
                metadata['OnlineResources']['OnlineResource']['Type'], 1)
        except TypeError:
            if metadata['OnlineResources'] != None:
                length = len(metadata['OnlineResources']['OnlineResource'])
                result[str] = self.checkerRules.checkOnlineResourceType(metadata['OnlineResources']['OnlineResource'],
                                                                    length)
            else:
                result[str] = "np"
        except:
            result[str] = "np"
        # ================
        str = "Orderable"
        try:
            result[str] = self.checkerRules.checkOrderable(metadata["Orderable"])
        except:
            result[str] = "np"
        # ================
        str = 'DataFormat'
        try:
            result[str] = self.checkerRules.checkDataFormat(metadata["DataFormat"])
        except KeyError:
            result[str] = "Recommend providing the data format for the associated granule"
        except:
            result[str] = "np"
        # ================
        str = 'Visible'
        try:
            result[str] = self.checkerRules.checkVisible(metadata["Visible"])
        except:
            result[str] = "np"
        return result
