'''This file is for get CSV output for Collection DIF data'''

class CollectionOutputJSON():
    def __init__(self,checkerRules,fetchAllPlatforms,fetchAllInstrs,fetchAllSciKeyWords):
        self.checkerRules = checkerRules
        self.fetchAllPlatforms = fetchAllPlatforms
        self.fetchAllInstrs = fetchAllInstrs
        self.fetchAllSciKeyWords = fetchAllSciKeyWords

    def checkAll(self, metadata):
        #print metadata
        result = {}
        result["Dataset Id (short name) - umm-json link"] = metadata["ShortName"]
        # ================
        str = 'ShortName'
        try:
            result[str] = self.checkerRules.checkShortName(metadata['ShortName'])
        except:
            result[str] = 'np'
        # ================
        str = 'VersionId'
        try:
            result[str] = self.checkerRules.checkVersionID(metadata['VersionId'])
        except:
            result[str] = 'np'
        # ================
        str = 'InsertTime'
        try:
            result[str] = self.checkerRules.checkInsertTime(metadata['InsertTime'])
        except KeyError:
            result[str] = 'Provide an insert time for this dataset. This is a required field.'
        except:
            result[str] = 'np'
        # ================
        str = 'LastUpdate'
        try:
            result[str] = self.checkerRules.checkLastUpdate(metadata['LastUpdate'])
        except KeyError:
            result[str] = 'Provide a last update time for this dataset. This is a required field.'
        except:
            result[str] = 'np'
        # ================
        str = 'LongName'
        try:
            result[str] = self.checkerRules.checkLongName(metadata['LongName'])
        except KeyError:
            result[str] = 'np'
        except:
            result[str] = 'np'
        # ================
        str = 'DataSetId'
        try:
            result[str] = self.checkerRules.checkDateSetID(metadata['DataSetId'],metadata['ShortName'])
        except KeyError:
            result[str] = 'Provide a Dataset Id for this dataset. This is a required field.'
        except:
            result[str] = 'np'
        # ================
        str = 'Description'
        try:
            result[str] = self.checkerRules.checkDesc(metadata['Description'])
        except KeyError:
            result[str] = 'Provide a description for this dataset. This is a required field.'
        except:
            result[str] = 'np'

        # ================
        str = 'DOI/DOI'
        try:
            result[str] = self.checkerRules.checkDOI(metadata['DOI']['DOI'])
        except KeyError:
            result[str] = "DOI is a required field in UMM. The DOI element has recently been added to ECHO10 metadata. If the data set has a DOI the DOI string should be provided here. If the data set does not have a DOI then this field should be included once a DOI has been registered for the data set."
        except:
            result[str] = 'np'
        # ================
        str = 'DOI/Authority'
        try:
            result[str] = self.checkerRules.checkDOIAuthority(metadata['DOI']['Authority'])
        except KeyError:
            result[str] = "np"
        except:
            result[str] = 'np'
        # ================
        # ================
        str = 'CollectionDataType'
        try:
            result[str] = self.checkerRules.checkCollectionDataType(metadata['CollectionDataType'])
        except KeyError:
            result[str] = 'np'
        except:
            result[str] = 'np'
            # ================
        str = 'Orderable'
        try:
            result[str] = self.checkerRules.checkOrderable(metadata['Orderable'])
        except:
            result[str] = 'np'
        # ================
        str = 'Visible'
        try:
            result[str] = self.checkerRules.checkVisible(metadata['Visible'])
        except:
            result[str] = 'np'
        # ================
        str = 'RevisionDate'
        try:
            result[str] = self.checkerRules.checkRevisionDate(metadata['RevisionDate'])
        except:
            result[str] = 'np'
        # ================
        str = 'ProcessingCenter'
        try:
            result[str] = self.checkerRules.checkProcCenter(metadata['ProcessingCenter'])
        except:
            result[str] = 'np'
        # ================
        str = 'ProcessingLevelId'
        try:
            result[str] = self.checkerRules.checkProcLevelID(metadata['ProcessingLevelId'])
        except KeyError:
            result[str] = 'Provide a processing level Id for this dataset. This is a required field.'
        except:
            result[str] = 'np'
        # ================
        str = 'ArchiveCenter'
        try:
            result[str] = self.checkerRules.checkArchiveCenter(metadata['ArchiveCenter'])
        except:
            result[str] = 'np'
        # ================
        str = 'CitationForExternalPublication'
        try:
            result[str] = self.checkerRules.checkExtPub(metadata['CitationForExternalPublication'])
        except:
            result[str] = 'np'
        # ================
        str = 'CollectionState'
        try:
            result[str] = self.checkerRules.checkCollectionState(metadata['CollectionState'])
        except KeyError:
            result[str] = 'Collection state is a required element in CMR. Please choose a collection state from one of the following options: PLANNED, IN WORK, COMPLETE'
        except:
            result[str] = 'np'
        # ================
        # try:
        #     result += self.checkRestrictFlag(metadata['RestrictionFlag']) + ', , '
        # except KeyError:
        #     result += 'np' + ', , '
        # ================
        #================
        str = 'RestrictionComment'
        try:
            result[str] = self.checkerRules.checkRestrictionComment(metadata['RestrictionComment'])
        except KeyError:
            result[str] = 'np'
        except:
            result[str] = 'np'
        #================
        str = 'DataFormat'
        try:
            result[str] = self.checkerRules.checkDateFormat(metadata['DataFormat'])
        except KeyError:
            result[str] = 'Recommend providing the data format(s) for this dataset.'
        except:
            result[str] = 'np'
        # ================
        # try:
        #     result += self.checkPrice(metadata['Price']) + ', '
        # except KeyError:
        #     result += 'np' + ', '
        # ================
        str = 'SpatialKeywords/Keyword'
        try:
            result[str] = self.checkerRules.checkSpatialKey(metadata['SpatialKeywords']['Keyword'])
        except KeyError:
            result[str] = 'Recommend providing a spatial keyword from the following keywords list: https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/locations?format=csv'
        except:
            result[str] = 'np'
        # ================
        # try:
        #     result += self.checkTemporalKeyword(metadata['TemporalKeywords']['Keyword'], 1) + ', , , , , , '
        # except KeyError:
        #     if metadata['TemporalKeywords'] != None:
        #         length = len(metadata['TemporalKeywords'])
        #         result += self.checkTemporalKeyword(metadata['TemporalKeywords'], length) + ', , , , , , '
        #     else:
        #         result += 'np' + ', , , , , , '
        # ================
        str = 'Temporal/SingleDateTime'
        try:
            result[str] = self.checkerRules.checkSingleDateTime(metadata['Temporal']['SingleDateTime'])
        except:
            result[str] = 'np'
        # ================
        str = 'Temporal/RangeDateTime/BeginningDateTime'
        try:
            result[str] = self.checkerRules.checkBeginDateTime(metadata['Temporal']['RangeDateTime']['BeginningDateTime'])
        except:
            result[str] = 'np'
        # ================
        str = 'Temporal/RangeDateTime/EndingDateTime'
        try:
            result[str] = self.checkerRules.checkEndDateTime(metadata['Temporal']['RangeDateTime']['EndingDateTime'])
        except:
            result[str] = 'np'
        # ================
        
        
        str = 'Contacts/Contact/Role'
        try:
            result[str] = self.checkerRules.checkContactRole(metadata['Contacts']['Contact']['Role'])
        except:
            xx = ""
            try:
                for item in metadata['Contacts']['Contact']:
                    try:
                        xx += self.checkerRules.checkContactRole(item['Role']) + ";"
                    except KeyError:
                        xx += 'np;'
                    except:
                        xx += 'np;'
            except:
                xx += "np"
            result[str] = xx
        # ================

       # print metadata['Contacts']['Contact']
        str = 'Contacts/Contact/OrganizationPhones'
        try:
            result[str] = self.checkerRules.checkContactPhone(metadata['Contacts']['Contact']['OrganizationPhones'],1) + ';'
        except:
            xx = ""
            try:
                for item in metadata['Contacts']['Contact']:
                    try:
                        if item['OrganizationPhones'] != None:
                            length = len(item['OrganizationPhones'])
                            xx += self.checkerRules.checkContactPhone(item['OrganizationPhones'],length) + ';'
                        else:
                            xx += 'np' + ';'
                    except:
                        xx += 'np' + ';'
            except:
                xx += 'np'
            result[str] = xx
        # ================
        str = 'Contacts/Contact/OrganizationEmails/Email'
        try:
            result[str] = self.checkerRules.checkContactEmail(metadata['Contacts']['Contact']['OrganizationEmails']['Email'], 1) + ';'
        except:
            xx = ""
            try:
                for item in metadata['Contacts']['Contact']:
                    try:
                        if item['OrganizationEmails'] != None:
                            length = len(item['OrganizationEmails'])
                            xx += self.checkerRules.checkContactEmail(item['OrganizationEmails'], length) + ';'
                        else:
                            xx += 'np;'
                    except:
                        xx += 'np;'
            except:
                xx += 'np'
            result[str] = xx
        # ================
        str = 'Contacts/Contact/ContactPersons/ContactPerson'
        try:
            if metadata['Contacts']['Contact']['ContactPersons'] == None:
                result[str] = 'np'
            else:
                result[str] = self.checkerRules.checkContactJobPosition(metadata['Contacts']['Contact']['ContactPersons']['ContactPerson'])
        except:
            result[str] = 'np'
        # ================
        str = 'ScienceKeywords/ScienceKeyword/CategoryKeyword'
        ScienceKeywords = self.fetchAllSciKeyWords()

        try:
            metadata['ScienceKeywords']['ScienceKeyword']['CategoryKeyword']
            result[str] = self.checkerRules.checkSciKeyCategory(metadata['ScienceKeywords']['ScienceKeyword'], 1, ScienceKeywords)
        except TypeError:
            try:
                if metadata['ScienceKeywords'] != None:
                    length = len(metadata['ScienceKeywords']['ScienceKeyword'])
                    result[str] = self.checkerRules.checkSciKeyCategory(metadata['ScienceKeywords']['ScienceKeyword'], length, ScienceKeywords)
                else:
                    result[str] = 'Provide at least one science category keyword for this dataset. This is a required field.'
            except:
                result[str] = 'np'
        except KeyError:
            result[str] = 'Provide at least one science category keyword for this dataset. This is a required field.'
        except:
            result[str] = 'np'
        # ================
        str = 'ScienceKeywords/ScienceKeyword/TopicKeyword'
        try:
            metadata['ScienceKeywords']['ScienceKeyword']['TopicKeyword']
            result[str] = self.checkerRules.checkSciKeyTopic(metadata['ScienceKeywords']['ScienceKeyword'], 1, ScienceKeywords)
        except TypeError:
            try:
                if metadata['ScienceKeywords'] != None:
                    length = len(metadata['ScienceKeywords']['ScienceKeyword'])
                    result[str] = self.checkerRules.checkSciKeyTopic(metadata['ScienceKeywords']['ScienceKeyword'], length, ScienceKeywords)
                else:
                    result[str] = 'Provide at least one science topic keyword for this dataset. This is a required field.'
            except:
                result[str] = 'np'
        except KeyError:
            result[str] = 'Provide at least one science topic keyword for this dataset. This is a required field.'
        except:
            result[str] = 'np'
        # ================
        str = 'ScienceKeywords/ScienceKeyword/TermKeyword'
        try:
            metadata['ScienceKeywords']['ScienceKeyword']['TermKeyword']
            result[str] = self.checkerRules.checkSciKeyTerm(metadata['ScienceKeywords']['ScienceKeyword'], 1, ScienceKeywords)
        except TypeError:
            try:
                if metadata['ScienceKeywords'] != None:
                    length = len(metadata['ScienceKeywords']['ScienceKeyword'])
                    result[str] = self.checkerRules.checkSciKeyTerm(metadata['ScienceKeywords']['ScienceKeyword'], length, ScienceKeywords)
                else:
                    result[str] = 'Provide at least one science term keyword for this dataset. This is a required field.'
            except:
                result[str] = 'np'
        except KeyError:
            result[str] = 'Provide at least one science term keyword for this dataset. This is a required field.'
        except:
            result[str] = 'np'
        # ================
        str = 'ScienceKeywords/ScienceKeyword/VariableLevel1Keyword/Value'
        try:
            metadata['ScienceKeywords']['ScienceKeyword']['VariableLevel1Keyword']['Value']
            result[str] = self.checkerRules.checkSciKeyVarL1(metadata['ScienceKeywords']['ScienceKeyword'], 1, ScienceKeywords)
        except TypeError:
            try:
                if metadata['ScienceKeywords'] != None:
                    length = len(metadata['ScienceKeywords']['ScienceKeyword'])
                    result[str] = self.checkerRules.checkSciKeyVarL1(metadata['ScienceKeywords']['ScienceKeyword'], length, ScienceKeywords)
                else:
                    result[str] = 'np'
            except:
                result[str] = 'np'
        except:
            result[str] = 'np'
        # ================
        str = 'ScienceKeywords/ScienceKeyword/VariableLevel1Keyword/VariableLevel2Keyword/Value'
        try:
            metadata['ScienceKeywords']['ScienceKeyword']['VariableLevel1Keyword']['VariableLevel2Keyword']['Value']
            result[str] = self.checkerRules.checkSciKeyVarL2(metadata['ScienceKeywords']['ScienceKeyword'], 1, ScienceKeywords)
        except TypeError:
            try:
                if metadata['ScienceKeywords'] != None:
                    length = len(metadata['ScienceKeywords']['ScienceKeyword'])
                    result[str] = self.checkerRules.checkSciKeyVarL2(metadata['ScienceKeywords']['ScienceKeyword'], length, ScienceKeywords)
                else:
                    result[str] = 'np'
            except:
                result[str] = 'np'
        except:
            result[str] = 'np'
        # ================
        str = 'ScienceKeywords/ScienceKeyword/VariableLevel1Keyword/VariableLevel2Keyword/VariableLevel3Keyword/Value'
        try:
            metadata['ScienceKeywords']['ScienceKeyword']['VariableLevel1Keyword']['VariableLevel2Keyword']['VariableLevel3Keyword']['Value']
            result[str] = self.checkerRules.checkSciKeyVarL3(metadata['ScienceKeywords']['ScienceKeyword'], 1, ScienceKeywords)
        except TypeError:
            try:
                if metadata['ScienceKeywords'] != None:
                    length = len(metadata['ScienceKeywords']['ScienceKeyword'])
                    result[str] = self.checkerRules.checkSciKeyVarL3(metadata['ScienceKeywords']['ScienceKeyword'], length, ScienceKeywords)
                else:
                    result[str] = 'np'
            except:
                result[str] = 'np'
        except:
            result[str] = 'np'
        # ================
        str = 'Platforms/Platform/ShortName'
        platforms = self.fetchAllPlatforms()
        PlatformShortName = []
        try:
            metadata['Platforms']['Platform']['ShortName']
            result[str] = self.checkerRules.checkPlatformShortName(metadata['Platforms']['Platform'], 1, platforms)
            PlatformShortName.append(metadata['Platforms']['Platform']['ShortName'])
        except TypeError:
            try:
                if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                    length = len(metadata['Platforms']['Platform'])
                    result[str] = self.checkerRules.checkPlatformShortName(metadata['Platforms']['Platform'], length, platforms)
                    for i in range(length):
                        PlatformShortName.append(metadata['Platforms']['Platform'][i]['ShortName'])
                else:
                    result[str] = 'Provide at least one platform for this dataset. This is a required field.'
            except:
                result[str] = 'np'
        except KeyError:
            result[str] = 'Provide at least one platform for this dataset. This is a required field.'
        # ================
        str = 'Platforms/Platform/LongName'
        try:
            metadata['Platforms']['Platform']['LongName']
            result[str] = self.checkerRules.checkPlatformLongName(metadata['Platforms']['Platform'], 1, PlatformShortName, platforms)
        except TypeError:
            if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                length = len(metadata['Platforms']['Platform'])
                result[str] = self.checkerRules.checkPlatformLongName(metadata['Platforms']['Platform'], length, PlatformShortName, platforms)
            else:
                result[str] = 'Recommend adding a Platform long name; if applicable.'
        except KeyError:
            result[str] = 'Recommend adding a Platform long name; if applicable.'
        except:
            result[str] = 'np'
        # ================
        str = 'Platforms/Platform/Type'
        try:
            metadata['Platforms']['Platform']['Type']
            result[str] = self.checkerRules.checkPlatformType(metadata['Platforms']['Platform'], 1, platforms)
        except TypeError:
            try:
                if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                    length = len(metadata['Platforms']['Platform'])
                    result[str] = self.checkerRules.checkPlatformType(metadata['Platforms']['Platform'], length, platforms)
                else:
                    result[str] = 'Provide at least one platform for this dataset. This is a required field.'
            except:
                result[str] = 'np'
        except KeyError:
                result[str] = 'Provide at least one platform for this dataset. This is a required field.'
        except:
            result[str] = 'np'
        # ================
        instruments = self.fetchAllInstrs()
        sensorShortResult = ''
        str = 'Platforms/Platform/Instruments/Instrument/ShortName'
        try:
            metadata['Platforms']['Platform']['ShortName']
            platform_num = 1
            ret, sensorShortResult = self.checkerRules.checkInstrShortName(metadata['Platforms']['Platform'], platform_num, instruments)
            result[str] = ret
        except TypeError:
            if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                platform_num = len(metadata['Platforms']['Platform'])
                ret, sensorShortResult = self.checkerRules.checkInstrShortName(metadata['Platforms']['Platform'], platform_num, instruments)
                result[str] = ret
            else:
                result[str] = 'Provide at least one relevant instrument for this dataset. This is a required field.'
        except KeyError:
            result[str] = 'Provide at least one relevant instrument for this dataset. This is a required field.'
        except:
            result[str] = 'np'
        # ================
        str = 'Platforms/Platform/Instruments/Instrument/LongName'
        sensorLongResult = ''
        try:
            metadata['Platforms']['Platform']['LongName']
            platform_num = 1
            ret, sensorLongResult = self.checkerRules.checkInstrLongName(metadata['Platforms']['Platform'], platform_num, instruments)
            result[str] = ret
        except TypeError:
            if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                platform_num = len(metadata['Platforms']['Platform'])
                ret, sensorLongResult = self.checkerRules.checkInstrLongName(metadata['Platforms']['Platform'], platform_num, instruments)
                result[str] = ret
            else:
                result[str] = "Recommend providing an Instrument/LongName since many Instrument/ShortNames are comprised of acronyms."
        except KeyError:
            result[str] = "Recommend providing an Instrument/LongName since many Instrument/ShortNames are comprised of acronyms."
        except:
            result[str] = 'np'
        # ================
        str = 'Platforms/Platform/Instruments/Instrument/Sensors/Sensor/ShortName'
        if len(sensorShortResult) == 0:
            result[str] = 'np'
        else:
            result[str] = sensorShortResult
        # ================
        str = 'Platforms/Platform/Instruments/Instrument/Sensors/Sensor/LongName'
        if len(sensorLongResult) == 0:
            result[str] = 'np'
        else:
            result[str] = sensorLongResult
        # ================
        str = 'Campaigns/Campaign/ShortName'
        if 'Campaigns' not in metadata:
            result[str] = 'np'
            str = 'Campaigns/Campaign/LongName'
            result[str] = 'Recommend providing a Campaign/LongName if applicable.'
        else:
            try:
                result[str] = self.checkerRules.checkCampaignShortName(metadata['Campaigns']['Campaign']['ShortName'], 1)
            except TypeError:
                if 'Campaigns' not in metadata: result += 'np' + ','
                length = len(metadata['Campaigns']['Campaign'])
                result[str] = self.checkerRules.checkCampaignShortName(metadata['Campaigns']['Campaign'], length)
            except:
                result[str] = 'np'
            # ================
            str = 'Campaigns/Campaign/LongName'
            try:
                result[str] = self.checkerRules.checkCampaignLongName(metadata['Campaigns']['Campaign']['LongName'], 1)
            except TypeError:
                length = len(metadata['Campaigns']['Campaign'])
                result[str] = self.checkerRules.checkCampaignLongName(metadata['Campaigns']['Campaign'], length)
            except:
                result[str] = 'np'
            # ================
            str = 'Campaigns/Campaign/StartDate'
            try:
                result[str] = self.checkerRules.checkCampaignStartDate(metadata['Campaigns']['Campaign']['StartDate'], 1)
            except TypeError:
                length = len(metadata['Campaigns']['Campaign'])
                result[str] = self.checkerRules.checkCampaignStartDate(metadata['Campaigns']['Campaign'], length)
            except:
                result[str] = 'np'
            # ================
            str = 'Campaigns/Campaign/EndDate'
            try:
                result[str] = self.checkerRules.checkCampaignEndDate(metadata['Campaigns']['Campaign']['EndDate'], 1)
            except TypeError:
                length = len(metadata['Campaigns']['Campaign'])
                result[str] = self.checkerRules.checkCampaignEndDate(metadata['Campaigns']['Campaign'], length)
            except:
                result[str] = 'np'
        # ================
        str = 'OnlineAccessURLs/OnlineAccessURL/URL'
        try:
            result[str] = self.checkerRules.checkOnlineAccessURL(metadata['OnlineAccessURLs']['OnlineAccessURL']['URL'], 1, metadata['ArchiveCenter'])
        except TypeError:
            if metadata['OnlineAccessURLs'] != None:
                length = len(metadata['OnlineAccessURLs']['OnlineAccessURL'])
                result[str] = self.checkerRules.checkOnlineAccessURL(metadata['OnlineAccessURLs']['OnlineAccessURL'], length, metadata['ArchiveCenter'])
            else:
                result[str] = "No OnlineAccessURL provided. Please provide at least one OnlineAccessURL as this is required in UMM. The OnlineAccessURL should point as directly to the data as possible (i.e. the user should not have to click through sub directories to access data pertinent to this collection) and the link should run through URS."
        except KeyError:
            result[str] = "No OnlineAccessURL provided. Please provide at least one OnlineAccessURL as this is required in UMM. The OnlineAccessURL should point as directly to the data as possible (i.e. the user should not have to click through sub directories to access data pertinent to this collection) and the link should run through URS."
        except:
            result[str] = 'np'
        # ================
        str = 'OnlineAccessURLs/OnlineAccessURL/URLDescription'
        try:
           # print metadata['OnlineAccessURLs']['OnlineAccessURL']
            result[str] = self.checkerRules.checkOnlineURLDesc(metadata['OnlineAccessURLs']['OnlineAccessURL']['URLDescription'], 1)
        except TypeError:
            if metadata['OnlineAccessURLs'] != None:
                length = len(metadata['OnlineAccessURLs']['OnlineAccessURL'])
                result[str] = self.checkerRules.checkOnlineURLDesc(metadata['OnlineAccessURLs']['OnlineAccessURL'], length)
            else:
                result[str] = 'Recommend providing descriptions for all Online Access URLs.'
        except KeyError:
            result[str] = 'Recommend providing descriptions for all Online Access URLs.'
        except:
            result[str] = 'np'
        # ================
        str = 'OnlineResources/OnlineResource/URL'
        try:
            result[str] = self.checkerRules.checkOnlineResourceURL(metadata['OnlineResources']['OnlineResource']['URL'], 1)
        except TypeError:
            if metadata['OnlineResources'] != None:
                length = len(metadata['OnlineResources']['OnlineResource'])
                result[str] = self.checkerRules.checkOnlineResourceURL(metadata['OnlineResources']['OnlineResource'], length)
            else:
                result[str] = 'np'
        except:
            result[str] = 'np'
        # ================
        str = 'OnlineResources/OnlineResource/Description'
        try:
            result[str] = self.checkerRules.checkOnlineResourceURLDesc(metadata['OnlineResources']['OnlineResource']['Description'], 1)
        except TypeError:
            try:
                if metadata['OnlineResources'] != None:
                    length = len(metadata['OnlineResources']['OnlineResource'])
                    result[str] = self.checkerRules.checkOnlineResourceURLDesc(metadata['OnlineResources']['OnlineResource'], length)
                else:
                    result[str] = 'np'
            except:
                result[str] = 'np'
        except:
            result[str] = 'np'
        # ================
        str = 'OnlineResources/OnlineResource/Type'
        try:
            result[str] = self.checkerRules.checkOnlineResourceType(metadata['OnlineResources']['OnlineResource']['Type'], 1)
        except TypeError:
            try:
                if metadata['OnlineResources'] != None:
                    length = len(metadata['OnlineResources']['OnlineResource'])
                    result[str] = self.checkerRules.checkOnlineResourceType(metadata['OnlineResources']['OnlineResource'], length)
                else:
                    result[str] = 'np'
            except:
                result[str] = 'np'
        except:
            result[str] = 'np'
        # ================
        str = 'Spatial/HorizontalSpatialDomain/Geometry/CoordinateSystem'
        try:
            result[str] = self.checkerRules.checkSpatialCorordinateSystem(metadata['Spatial']['HorizontalSpatialDomain']['Geometry']['CoordinateSystem'])
        except:
            result[str] = 'This field is required in CMR. Provide one of the following values for coordinate system: CARTESIAN; GEODETIC'
        # ================
        # result += self.checkSpatialHorGeoCoor(metadata['Spatial']['HorizontalSpatialDomain']['Geometry']['CoordinateSystem']) + ', '
        # ================
        str = 'Spatial/HorizontalSpatialDomain/Geometry/BoundingRectangle'
        try:
            result[str] = self.checkerRules.checkBoundingRectangle(metadata['Spatial']['HorizontalSpatialDomain']['Geometry']['BoundingRectangle'])
        except:
            result[str] = 'np'
        # # ================
        # try:
        #     result += self.checkSpatialGranuleRepresent(metadata['Spatial']['GranuleSpatialRepresentation']) + ', , , , , , , , , , , '
        # except KeyError:
        #     result += 'Provide a granule spatial representation for this dataset. This is a required field.' + ', , , , , , , , , , , '
        # # ================
        # try:
        #     result += self.checkSpatInfoHorGeoDatumName(metadata['SpatialInfo']['HorizontalCoordinateSystem']['GeodeticModel']['HorizontalDatumName']) + ', '
        # except KeyError:
        #     result += 'np'
        # # ================
        str = 'Spatial/GranuleSpatialRepresentation'
        try:
            result[str] = self.checkerRules.checkSpatialGranuleRepresent(metadata['Spatial']['GranuleSpatialRepresentation'])
        except:
            result[str] = 'np'
        str = 'SpatialInfo/HorizontalCoordinateSystem/GeodeticModel/HorizontalDatumName'
        try:
            result[str] = self.checkerRules.checkFieldNoneEmpty(metadata,
                                                        "SpatialInfo/HorizontalCoordinateSystem/GeodeticModel/HorizontalDatumName",
                                                        "OK - quality check",
                                                        "Recommend providing information about the datum if possible.")
        except:
            result[str] = 'np'
        return result
