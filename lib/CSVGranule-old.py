'''This file is for get CSV output for Collection DIF data'''

class GranuleOutputCSV():
    def __init__(self,checkerRules,fetchAllInstrs):
        self.checkerRules = checkerRules
        self.fetchAllInstrs = fetchAllInstrs

    def checkAll(self, metadata):
        result = ", "
        # result += self.checkGranuleUR(metadata['GranuleUR']) + ', '
        # ================
        try:
            result += self.checkerRules.checkInsertTime(metadata['InsertTime']) + ', '
        except KeyError:
            result += "np" + ', '

        except:
            result += "np" + ','
        # ================
        try:
            result += self.checkerRules.checkLastUpdate(metadata['LastUpdate'],
                                                        metadata['DataGranule']['ProductionDateTime']) + ', '
        except KeyError:
            result += "np" + ', '
        except:
            result += "np" + ','
        # ================
        try:
            result += self.checkerRules.checkDeleteTime(metadata['DeleteTime'],
                                                        metadata['DataGranule']['ProductionDateTime']) + ', '
        except KeyError:
            result += "np" + ', '
        except:
            result += "np" + ','
        # ================
        try:
            result += self.checkerRules.checkCollectionShortName(metadata['Collection']['ShortName']) + ', '
        except KeyError:
            result += "np - Ensure the DataSetId field is provided." + ', '
        except:
            result += "np" + ','
        # =================
        try:
            result += self.checkerRules.checkCollectionVersionID(metadata['Collection']['VersionId']) + ', '
        except KeyError:
            result += "np - Ensure the DataSetId field is provided." + ', '
        except:
            result += "np" + ','
        # ================
        try:
            result += self.checkerRules.checkDataSetId(metadata['Collection']['DataSetId']) + ', , , '
        except KeyError:
            result += "np - Ensure that the ShortName and VersionId fields are provided." + ', , , '
        except:
            result += "np" + ',,,'
        # ================
        try:
            result += self.checkerRules.checkSizeMBDataGranule(
                metadata['DataGranule']['SizeMBDataGranule']) + ', , , ,'
        except KeyError:
            result += "Granule file size not provided. Recommend providing a value for this field in the metadata" + ', , , ,'
        except:
            result += "np" + ',,,,'
        # ================
        try:
            result += self.checkerRules.checkDayNightFlag(metadata['DataGranule']['DayNightFlag']) + ', '
        except KeyError:
            result += "np" + ', '
        except:
            result += "np" + ','
        # ================
        try:
            result += self.checkerRules.checkProductionDateTime(metadata['DataGranule']['ProductionDateTime'],
                                                                metadata['InsertTime']) + ', , , , '
        except KeyError:
            result += "np" + ', , , , '
        except:
            result += "np" + ',,,,'
        # ================
        try:
            result += self.checkerRules.checkTemporalSingleTime(
                metadata['Temporal']['RangeDateTime']['SingleDateTime']) + ', '
        except KeyError:
            result += "np" + ', '
        except:
            result += "np" + ','
        # ================
        try:
            result += self.checkerRules.checkTemporalBeginningTime(
                metadata['Temporal']['RangeDateTime']['BeginningDateTime']) + ', '
        except KeyError:
            result += "np" + ', '
        except:
            result += "np" + ','
        # ================
        try:
            result += self.checkerRules.checkTemporalEndingTime(
                metadata['Temporal']['RangeDateTime']['EndingDateTime']) + ', , , , , , , '
        except KeyError:
            result += "np" + ', , , , , , , '
        except:
            result += "np" + ', , , , , , , '
        # ================
        try:
            result += self.checkerRules.checkBoundingRectangle(
                metadata['Spatial']['HorizontalSpatialDomain']['Geometry'][
                    'BoundingRectangle']) + ',,,,,,,,,,,,,,,,,,,,,,,'
        except KeyError:
            result += "np, np, np, np" + ',,,,,,,,,,,,,,,,,,,,,,,,, '
        except:
            result += "np, np, np, np" + ',,,,,,,,,,,,,,,,,,,,,,,,, '
        # ================
        try:
            result += self.checkerRules.checkEquatorCrossingTime(
                metadata['OrbitCalculatedSpatialDomains']['OrbitCalculatedSpatialDomain'][
                    'EquatorCrossingDateTime'], 1) + ', , , , , , , , , , , , ,'
        except TypeError:
            if metadata['OrbitCalculatedSpatialDomains'] != None and metadata['OrbitCalculatedSpatialDomains'][
                'OrbitCalculatedSpatialDomain'] != None:
                length = len(metadata['OrbitCalculatedSpatialDomains']['OrbitCalculatedSpatialDomain'])
                result += self.checkerRules.checkEquatorCrossingTime(
                    metadata['OrbitCalculatedSpatialDomains']['OrbitCalculatedSpatialDomain'][
                        'EquatorCrossingDateTime'], length) + ', , , , , , , , , , , ,,'
            else:
                result += "np" + ', ,, , , , , , , , , , , '
        except KeyError:
            result += "np" + ', ,, , , , , , , , , , , '
        except:
            result += "np" + ', ,, , , , , , , , , , , '
        # ================
        try:
            result += self.checkerRules.checkPlatformShortName(metadata['Platforms']['Platform']['ShortName'],
                                                               1) + ', '
        except TypeError:
            if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                length = len(metadata['Platforms']['Platform'])
                result += self.checkerRules.checkPlatformShortName(metadata['Platforms']['Platform'], length) + ', '
            else:
                result += "np" + ', '
        except KeyError:
            result += "np" + ', '
        except:
            result += "np" + ', '
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
        instruments = self.fetchAllInstrs
        sensorShortResult = ''
        try:
            metadata['Platforms']['Platform']['ShortName']
            platform_num = 1
            ret, sensorShortResult = self.checkerRules.checkInstrShortName(metadata['Platforms']['Platform'],
                                                                           platform_num, instruments)
            result += ret + ', , , '
        except TypeError:
            if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                platform_num = len(metadata['Platforms']['Platform'])
                ret, sensorShortResult = self.checkerRules.checkInstrShortName(metadata['Platforms']['Platform'],
                                                                               platform_num, instruments)
                result += ret + ', , , '
            else:
                result += 'np' + ', , , '
        except KeyError:
            result += 'np' + ', , , '
        except:
            result += "np" + ', , , '
        # ================
        if len(sensorShortResult) == 0:
            result += 'np , , , , '
        else:
            result += sensorShortResult + ', , , , '
        # ================
        try:
            campaign_num = 1
            result += self.checkerRules.checkCampaignShortName(metadata['Campaigns']['Campaign']['ShortName'],
                                                               campaign_num) + ', , , , , , , , , , '
        except TypeError:
            if metadata['Campaigns'] != None and metadata['Campaigns']['Campaign'] != None:
                campaign_num = len(metadata['Campaigns'])
                result += self.checkerRules.checkCampaignShortName(metadata['Campaigns'],
                                                                   campaign_num) + ', , , , , , , , , , '
        except KeyError:
            result += "np" + ', , , , , , , , , , '
        except:
            result += "np" + ', , , , , , , , , , '
        # ================
        try:
            result += self.checkerRules.checkOnlineAccessURL(metadata['OnlineAccessURLs']['OnlineAccessURL']['URL'],
                                                             1) + ', '
        except TypeError:
            if metadata['OnlineAccessURLs'] != None:
                length = len(metadata['OnlineAccessURLs']['OnlineAccessURL'])
                result += self.checkerRules.checkOnlineAccessURL(metadata['OnlineAccessURLs']['OnlineAccessURL'],
                                                                 length) + ', '
            else:
                result += "No Online Access URL is provided" + ', '
        except KeyError:
            result += "No Online Access URL is provided" + ', '
        except:
            result += "np" + ','
        # ================
        try:
            result += self.checkerRules.checkOnlineAccessURLDesc(
                metadata['OnlineAccessURLs']['OnlineAccessURL']['URLDescription'], 1) + ', , '
        except TypeError:
            if metadata['OnlineAccessURLs'] != None:
                length = len(metadata['OnlineAccessURLs']['OnlineAccessURL'])
                result += self.checkerRules.checkOnlineAccessURLDesc(
                    metadata['OnlineAccessURLs']['OnlineAccessURL'], length) + ', , '
            else:
                result += "Recommend providing a brief URL description" + ', ,'
        except KeyError:
            result += "Recommend providing a brief URL description" + ', ,'
        except:
            result += "np" + ', ,'
        # ================
        OnlineResourceURL_Cnt = 0
        try:
            result += self.checkerRules.checkOnlineResourceURL(metadata['OnlineResources']['OnlineResource']['URL'],
                                                               1) + ', '
            OnlineResourceURL_Cnt = 1
        except TypeError:
            if metadata['OnlineResources'] != None:
                length = len(metadata['OnlineResources']['OnlineResource'])
                OnlineResourceURL_Cnt = length
                result += self.checkerRules.checkOnlineResourceURL(metadata['OnlineResources']['OnlineResource'],
                                                                   length) + ', '
            else:
                result += "np" + ', '
        except KeyError:
            result += "np" + ', '
        except:
            result += "np" + ', '
        # ================
        try:
            result += self.checkerRules.checkOnlineResourceDesc(
                metadata['OnlineResources']['OnlineResource']['Description'], 1) + ', '
        except TypeError:
            if metadata['OnlineResources'] != None:
                length = len(metadata['OnlineResources']['OnlineResource'])
                if length < OnlineResourceURL_Cnt:
                    result += "Recommend providing descriptions for all Online Resource URLs." + ', '
                else:
                    result += self.checkerRules.checkOnlineResourceDesc(
                        metadata['OnlineResources']['OnlineResource'], length) + ', '
            else:
                result += "np" + ', '
        except KeyError:
            result += "np" + ', '
        except:
            result += "np" + ', '
        # ================
        try:
            result += self.checkerRules.checkOnlineResourceType(
                metadata['OnlineResources']['OnlineResource']['Type'], 1) + ', , '
        except TypeError:
            if metadata['OnlineResources'] != None:
                length = len(metadata['OnlineResources']['OnlineResource'])
                result += self.checkerRules.checkOnlineResourceType(metadata['OnlineResources']['OnlineResource'],
                                                                    length) + ', , '
            else:
                result += "np" + ', , '
        except KeyError:
            result += "np" + ', , '
        except:
            result += "np" + ', ,'
        # ================
        try:
            result += self.checkerRules.checkOrderable(metadata["Orderable"]) + ', '
        except KeyError:
            result += "np" + ', '
        except:
            result += "np" + ', '
        # ================
        try:
            result += self.checkerRules.checkDataFormat(metadata["DataFormat"]) + ', '
        except KeyError:
            result += "Recommend providing the data format for the associated granule" + ', '
        except:
            result += "np" + ', '
        # ================
        try:
            result += self.checkerRules.checkVisible(metadata["Visible"]) + ', , , , , , , '
        except KeyError:
            result += "np" + ', , , , , , , '
        except:
            result += "np" + ', , , , , , , '
        return result