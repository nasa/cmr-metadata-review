'''This file is for get CSV output for Collection DIF data'''

class CollectionOutputCSVBackup():
    def __init__(self,checkerRules,fetchAllPlatforms,fetchAllInstrs,fetchAllSciKeyWords):
        self.checkerRules = checkerRules
        self.fetchAllPlatforms = fetchAllPlatforms
        self.fetchAllInstrs = fetchAllInstrs
        self.fetchAllSciKeyWords = fetchAllSciKeyWords

    def checkAll(self, metadata):
        #print metadata
        result = ""
        result += self.checkerRules.checkShortName(metadata['ShortName']) + ', '
        result += self.checkerRules.checkVersionID(metadata['VersionId']) + ', '
        # ================
        try:
            result += self.checkerRules.checkInsertTime(metadata['InsertTime']) + ', '
        except KeyError:
            result += 'Provide an insert time for this dataset. This is a required field.' + ', '
        except:
            result += 'np' + ', '
        # ================
        try:
            result += self.checkerRules.checkLastUpdate(metadata['LastUpdate']) + ', '
        except KeyError:
            result += 'Provide a last update time for this dataset. This is a required field.' + ', '
        except:
            result += 'np' + ', '
        # ================
        try:
            result += self.checkerRules.checkLongName(metadata['LongName']) + ','
        except KeyError:
            result += 'np' + ','
        except:
            result += 'np' + ', '
        # ================
        try:
            result += self.checkerRules.checkDateSetID(metadata['DataSetId'],metadata['ShortName']) + ','
        except KeyError:
            result += 'Provide a Dataset Id for this dataset. This is a required field.' + ','
        except:
            result += 'np' + ', '
        # ================
        try:
            result += self.checkerRules.checkDesc(metadata['Description']) + ','
        except KeyError:
            result += 'Provide a description for this dataset. This is a required field.' + ','
        except:
            result += 'np' + ', '

        # ================
        try:
            result += self.checkerRules.checkDOI(metadata['DOI']['DOI']) + ','
        except KeyError:
            result += "DOI is a required field in UMM. The DOI element has recently been added to ECHO10 metadata. If the data set has a DOI the DOI string should be provided here. If the data set does not have a DOI then this field should be included once a DOI has been registered for the data set." + ','
        except:
            result += 'np' + ', '

        # ================
        try:
            result += self.checkerRules.checkDOIAuthority(metadata['DOI']['DOIAuthority']) + ','
        except KeyError:
            result += "np" + ','
        except:
            result += 'np' + ', '

        # ================
        try:
            result += self.checkerRules.checkCollectionDataType(metadata['CollectionDataType']) + ', '
        except KeyError:
            result += 'np' + ', '
        except:
            result += 'np' + ', '
            # ================
        try:
            result += self.checkerRules.checkOrderable(metadata['Orderable']) + ', '
        except KeyError:
            result += 'np' + ', '
        except:
            result += 'np' + ', '
        # ================
        try:
            result += self.checkerRules.checkVisible(metadata['Visible']) + ', '
        except KeyError:
            result += 'np' + ', '
        except:
            result += 'np' + ', '
        # ================
        try:
            result += self.checkerRules.checkRevisionDate(metadata['RevisionDate']) + ', , '
        except KeyError:
            result += 'np' + ', , '
        except:
            result += 'np' + ', ,'
        # ================
        try:
            result += self.checkerRules.checkProcCenter(metadata['ProcessingCenter']) + ', '
        except KeyError:
            result += 'np' + ', '
        except:
            result += 'np' + ', '
        # ================
        try:
            result += self.checkerRules.checkProcLevelID(metadata['ProcessingLevelId']) + ', , '
        except KeyError:
            result += 'Provide a processing level Id for this dataset. This is a required field.' + ', , '
        except:
            result += 'np' + ', , '
        # ================
        try:
            result += self.checkerRules.checkArchiveCenter(metadata['ArchiveCenter']) + ', , '
        except KeyError:
            result += 'np' + ', , '
        except:
            result += 'np' + ', , '
        # ================
        try:
            result += self.checkerRules.checkExtPub(metadata['CitationForExternalPublication']) + ','
        except KeyError:
            result += 'np' + ','
        except:
            result += 'np' + ', '
        # ================
        try:
            result += self.checkerRules.checkCollectionState(metadata['CollectionState']) + ', , ,'
        except KeyError:
            result += '"Collection state is a required element in CMR. Please choose a collection state from one of the following options: PLANNED, IN WORK, COMPLETE"' + ', , ,'
        except:
            result += 'np' + ', , ,'
        # ================
        # try:
        #     result += self.checkRestrictFlag(metadata['RestrictionFlag']) + ', , '
        # except KeyError:
        #     result += 'np' + ', , '
        # ================
        #================
        try:
            result += self.checkerRules.checkRestrictionComment(metadata['RestrictionComment']) + ',, '
        except KeyError:
            result += 'np' + ',,'
        except:
            result += 'np' + ', ,'
        #================
        try:
            result += self.checkerRules.checkDateFormat(metadata['DataFormat']) + ', '
        except KeyError:
            result += 'Recommend providing the data format(s) for this dataset.' + ', '
        except:
            result += 'np' + ', '
        # ================
        # try:
        #     result += self.checkPrice(metadata['Price']) + ', '
        # except KeyError:
        #     result += 'np' + ', '
        # ================
        try:
            result += self.checkerRules.checkSpatialKey(metadata['SpatialKeywords']['Keyword']) + ', , , , , , , '
        except KeyError:
            result += 'Recommend providing a spatial keyword from the following keywords list: http://gcmdservices.gsfc.nasa.gov/static/kms/locations/locations.csv' + ', , , , , , , '
        except:
            result += 'np' + ', , , , , , , '
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
        try:
            result += self.checkerRules.checkSingleDateTime(metadata['Temporal']['SingleDateTime']) + ', '
        except KeyError:
            result += 'np' + ', '
        except:
            result += 'np' + ', '
        # ================
        try:
            result += self.checkerRules.checkBeginDateTime(metadata['Temporal']['RangeDateTime']['BeginningDateTime']) + ','
        except KeyError:
            result += 'np' + ', '
        except:
            result += 'np' + ', '
        # ================
        try:
            result += self.checkerRules.checkEndDateTime(metadata['Temporal']['RangeDateTime']['EndingDateTime']) + ', , , , , , , ,'
        except KeyError:
            result += 'np' + ', , , , , , , ,'
        except:
            result += 'np' + ', , , , , , , ,'
        # ================
        try:
            result += self.checkerRules.checkContactRole(metadata['Contacts']['Contact']['Role'])
        except:
            for item in metadata['Contacts']['Contact']:
                try:
                    result += self.checkerRules.checkContactRole(item['Role']) + ";"
                except KeyError:
                    result += 'np;'
                except:
                    result += 'np;'
        result += ', , , , , , , , , ,'
        # ================

       # print metadata['Contacts']['Contact']
        try:
            result += self.checkerRules.checkContactPhone(metadata['Contacts']['Contact']['OrganizationPhones'],1) + ';'
        except:
            try:
                for item in metadata['Contacts']['Contact']:
                    try:
                        if item['OrganizationPhones'] != None:
                            length = len(item['OrganizationPhones'])
                            result += self.checkerRules.checkContactPhone(item['OrganizationPhones'],length) + ';'
                        else:
                            result += 'np' + ';'
                    except:
                        result += 'np' + ';'
            except:
                result += 'np' + ','
        result += ','
        # ================
        try:
            result += self.checkerRules.checkContactEmail(metadata['Contacts']['Contact']['OrganizationEmails']['Email'], 1) + ';'
        except:
            try:
                for item in metadata['Contacts']['Contact']:
                    try:
                        if item['OrganizationEmails'] != None:
                            length = len(item['OrganizationEmails'])
                            result += self.checkerRules.checkContactEmail(item['OrganizationEmails'], length) + ';'
                        else:
                            result += 'np;'
                    except:
                        result += 'np;'
            except:
                result += 'np' + ', , , ,'

        result += ', , , ,'
        # ================
        try:
            if metadata['Contacts']['Contact']['ContactPersons'] == None:
                result += 'np' + ', '
            else:
                result += self.checkerRules.checkContactJobPosition(metadata['Contacts']['Contact']['ContactPersons']['ContactPerson']) + ','
        except:
            result += 'np' + ','
        # ================
        ScienceKeywords = self.fetchAllSciKeyWords()

        #print metadata['ScienceKeywords']['ScienceKeyword']
        try:
            metadata['ScienceKeywords']['ScienceKeyword']['CategoryKeyword']
            result += self.checkerRules.checkSciKeyCategory(metadata['ScienceKeywords']['ScienceKeyword'], 1, ScienceKeywords) + ', '
        except TypeError:
            try:
                if metadata['ScienceKeywords'] != None:
                    length = len(metadata['ScienceKeywords']['ScienceKeyword'])
                    result += self.checkerRules.checkSciKeyCategory(metadata['ScienceKeywords']['ScienceKeyword'], length, ScienceKeywords) + ', '
                else:
                    result += 'Provide at least one science category keyword for this dataset. This is a required field.' + ', '
            except:
                result += 'np' + ','
        except KeyError:
            result += 'Provide at least one science category keyword for this dataset. This is a required field.' + ', '
        except:
            result += 'np' + ','
        # ================
        try:
            metadata['ScienceKeywords']['ScienceKeyword']['TopicKeyword']
            result += self.checkerRules.checkSciKeyTopic(metadata['ScienceKeywords']['ScienceKeyword'], 1, ScienceKeywords) + ', '
        except TypeError:
            try:
                if metadata['ScienceKeywords'] != None:
                    length = len(metadata['ScienceKeywords']['ScienceKeyword'])
                    result += self.checkerRules.checkSciKeyTopic(metadata['ScienceKeywords']['ScienceKeyword'], length, ScienceKeywords) + ', '
                else:
                    result += 'Provide at least one science topic keyword for this dataset. This is a required field.' + ', '
            except:
                result += 'np' + ','
        except KeyError:
            result += 'Provide at least one science topic keyword for this dataset. This is a required field.' + ', '
        except:
            result += 'np' + ','
        # ================
        try:
            metadata['ScienceKeywords']['ScienceKeyword']['TermKeyword']
            result += self.checkerRules.checkSciKeyTerm(metadata['ScienceKeywords']['ScienceKeyword'], 1, ScienceKeywords) + ', '
        except TypeError:
            try:
                if metadata['ScienceKeywords'] != None:
                    length = len(metadata['ScienceKeywords']['ScienceKeyword'])
                    result += self.checkerRules.checkSciKeyTerm(metadata['ScienceKeywords']['ScienceKeyword'], length, ScienceKeywords) + ', '
                else:
                    result += 'Provide at least one science term keyword for this dataset. This is a required field.' + ', '
            except:
                result += 'np' + ','
        except KeyError:
            result += 'Provide at least one science term keyword for this dataset. This is a required field.' + ', '
        except:
            result += 'np' + ','
        # ================
        try:
            metadata['ScienceKeywords']['ScienceKeyword']['VariableLevel1Keyword']['Value']
            result += self.checkerRules.checkSciKeyVarL1(metadata['ScienceKeywords']['ScienceKeyword'], 1, ScienceKeywords) + ', '
        except TypeError:
            try:
                if metadata['ScienceKeywords'] != None:
                    length = len(metadata['ScienceKeywords']['ScienceKeyword'])
                    result += self.checkerRules.checkSciKeyVarL1(metadata['ScienceKeywords']['ScienceKeyword'], length, ScienceKeywords) + ', '
                else:
                    result += 'np' + ', '
            except:
                result += 'np' + ','

        except KeyError:
            result += 'np' + ', '
        except:
            result += 'np' + ','
        # ================
        try:
            metadata['ScienceKeywords']['ScienceKeyword']['VariableLevel1Keyword']['VariableLevel2Keyword']['Value']
            result += self.checkerRules.checkSciKeyVarL2(metadata['ScienceKeywords']['ScienceKeyword'], 1, ScienceKeywords) + ', '
        except TypeError:
            try:
                if metadata['ScienceKeywords'] != None:
                    length = len(metadata['ScienceKeywords']['ScienceKeyword'])
                    result += self.checkerRules.checkSciKeyVarL2(metadata['ScienceKeywords']['ScienceKeyword'], length, ScienceKeywords) + ', '
                else:
                    result += 'np' + ', '
            except:
                result += 'np' + ','
        except KeyError:
            result += 'np' + ', '
        except:
            result += 'np' + ','
        # ================
        try:
            metadata['ScienceKeywords']['ScienceKeyword']['VariableLevel1Keyword']['VariableLevel2Keyword']['VariableLevel3Keyword']['Value']
            result += self.checkerRules.checkSciKeyVarL3(metadata['ScienceKeywords']['ScienceKeyword'], 1, ScienceKeywords) + ', , '
        except TypeError:
            try:
                if metadata['ScienceKeywords'] != None:
                    length = len(metadata['ScienceKeywords']['ScienceKeyword'])
                    result += self.checkerRules.checkSciKeyVarL3(metadata['ScienceKeywords']['ScienceKeyword'], length, ScienceKeywords) + ', , '
                else:
                    result += 'np' + ', , '
            except:
                result += 'np' + ', , '
        except KeyError:
            result += 'np' + ', , '
        except:
            result += 'np' + ', , '
        # ================
        platforms = self.fetchAllPlatforms()
        PlatformShortName = []
        try:
            metadata['Platforms']['Platform']['ShortName']
            result += self.checkerRules.checkPlatformShortName(metadata['Platforms']['Platform'], 1, platforms) + ', '
            PlatformShortName.append(metadata['Platforms']['Platform']['ShortName'])
        except TypeError:
            try:
                if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                    length = len(metadata['Platforms']['Platform'])
                    result += self.checkerRules.checkPlatformShortName(metadata['Platforms']['Platform'], length, platforms) + ', '
                    for i in range(length):
                        PlatformShortName.append(metadata['Platforms']['Platform'][i]['ShortName'])
                else:
                    result += 'Provide at least one platform for this dataset. This is a required field.' + ', '
            except:
                result += 'np' + ','
        except KeyError:
            result += 'Provide at least one platform for this dataset. This is a required field.' + ', '
        # ================
        try:
            metadata['Platforms']['Platform']['LongName']
            result += self.checkerRules.checkPlatformLongName(metadata['Platforms']['Platform'], 1, PlatformShortName, platforms) + ', '
        except TypeError:
            if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                length = len(metadata['Platforms']['Platform'])
                result += self.checkerRules.checkPlatformLongName(metadata['Platforms']['Platform'], length, PlatformShortName, platforms) + ', '
            else:
                result += 'Recommend adding a Platform long name; if applicable.' + ', '
        except KeyError:
            result += 'Recommend adding a Platform long name; if applicable.' + ', '
        except:
            result += 'np' + ','
        # ================
        try:
            metadata['Platforms']['Platform']['Type']
            result += self.checkerRules.checkPlatformType(metadata['Platforms']['Platform'], 1, platforms) + ', , , , , , '
        except TypeError:
            try:
                if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                    length = len(metadata['Platforms']['Platform'])
                    result += self.checkerRules.checkPlatformType(metadata['Platforms']['Platform'], length, platforms) + ', , , , , , '
                else:
                    result += 'Provide at least one platform for this dataset. This is a required field.' + ', , , , , , '
            except:
                result += 'np' + ', , , , , ,'
        except KeyError:
                result += 'Provide at least one platform for this dataset. This is a required field.' + ', , , , , , '
        except:
            import sys
            #print "Unexpected error:", sys.exc_info()[0]
            result += 'np' + ',,,,,,'
        # ================
        instruments = self.fetchAllInstrs()
        sensorShortResult = ''
        try:
            metadata['Platforms']['Platform']['ShortName']
            platform_num = 1
            ret, sensorShortResult = self.checkerRules.checkInstrShortName(metadata['Platforms']['Platform'], platform_num, instruments)
            result += ret + ', '
        except TypeError:
            if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                platform_num = len(metadata['Platforms']['Platform'])
                ret, sensorShortResult = self.checkerRules.checkInstrShortName(metadata['Platforms']['Platform'], platform_num, instruments)
                result += ret + ', '
            else:
                result += 'Provide at least one relevant instrument for this dataset. This is a required field.' + ', '
        except KeyError:
            result += 'Provide at least one relevant instrument for this dataset. This is a required field.' + ', '
        except:
            result += 'np' + ','
        # ================
        sensorLongResult = ''
        try:
            metadata['Platforms']['Platform']['LongName']
            platform_num = 1
            ret, sensorLongResult = self.checkerRules.checkInstrLongName(metadata['Platforms']['Platform'], platform_num, instruments)
            result += ret + ', , , , , , , , '
        except TypeError:
            if metadata['Platforms'] != None and metadata['Platforms']['Platform'] != None:
                platform_num = len(metadata['Platforms']['Platform'])
                ret, sensorLongResult = self.checkerRules.checkInstrLongName(metadata['Platforms']['Platform'], platform_num, instruments)
                result += ret + ', , , , , , , , '
            else:
                result += "Recommend providing an Instrument/LongName since many Instrument/ShortNames are comprised of acronyms." + ', , , , , , , , '
        except KeyError:
            result += "Recommend providing an Instrument/LongName since many Instrument/ShortNames are comprised of acronyms." + ', , , , , , , , '
        except:
            result += 'np' + ', , , , , , , ,'
        # ================
        if len(sensorShortResult) == 0:
            result += 'np , '
        else:
            result += sensorShortResult + ', '
        # ================
        if len(sensorLongResult) == 0:
            result += 'np , , , , , , , , , , , , , , , , , , , , , , ,,,,'
        else:
            result += sensorLongResult + ', , , , , , , , , , , , , , , , , , , , , , ,,,,'
        # ================

        if 'Campaigns' not in metadata:
            result += 'np,Recommend providing a Campaign/LongName if applicable.,np,np' + ',,,,,,'
        else:
            try:
                result += self.checkerRules.checkCampaignShortName(metadata['Campaigns']['Campaign']['ShortName'], 1) + ', '
            except TypeError:
                if(metadata['Campaigns'] == None): result += 'np' + ','
                length = len(metadata['Campaigns']['Campaign'])
                result += self.checkerRules.checkCampaignShortName(metadata['Campaigns']['Campaign'], length) + ', '
            except:
                result += 'np' + ', '
            # ================
            try:
                result += self.checkerRules.checkCampaignLongName(metadata['Campaigns']['Campaign']['LongName'], 1) + ', '
            except TypeError:
                length = len(metadata['Campaigns']['Campaign'])
                result += self.checkerRules.checkCampaignLongName(metadata['Campaigns']['Campaign'], length) + ', '
            except KeyError:
                result += 'np' + ', '
            except:
                result += 'np' + ', '
            # ================
            try:
                result += self.checkerRules.checkCampaignStartDate(metadata['Campaigns']['Campaign']['StartDate'], 1) + ', '
            except TypeError:
                length = len(metadata['Campaigns']['Campaign'])
                result += self.checkerRules.checkCampaignStartDate(metadata['Campaigns']['Campaign'], length) + ', '
            except KeyError:
                result += 'np' + ', '
            except:
                result += 'np' + ', '
            # ================
            try:
                result += self.checkerRules.checkCampaignEndDate(metadata['Campaigns']['Campaign']['EndDate'], 1) + ', , , , , , '
            except TypeError:
                length = len(metadata['Campaigns']['Campaign'])
                result += self.checkerRules.checkCampaignEndDate(metadata['Campaigns']['Campaign'], length) + ', , , , , , '
            except KeyError:
                result += 'np' + ', , , , , , '
            except:
                result += 'np' + ',,,,,,'
        # ================
        try:
            result += self.checkerRules.checkOnlineAccessURL(metadata['OnlineAccessURLs']['OnlineAccessURL']['URL'], 1, metadata['ArchiveCenter']) + ','
        except TypeError:
            if metadata['OnlineAccessURLs'] != None:
                length = len(metadata['OnlineAccessURLs']['OnlineAccessURL'])
                result += self.checkerRules.checkOnlineAccessURL(metadata['OnlineAccessURLs']['OnlineAccessURL'], length, metadata['ArchiveCenter']) + ','
            else:
                result += "No OnlineAccessURL provided. Please provide at least one OnlineAccessURL as this is required in UMM. The OnlineAccessURL should point as directly to the data as possible (i.e. the user should not have to click through sub directories to access data pertinent to this collection) and the link should run through URS." + ','
        except KeyError:
            result += "No OnlineAccessURL provided. Please provide at least one OnlineAccessURL as this is required in UMM. The OnlineAccessURL should point as directly to the data as possible (i.e. the user should not have to click through sub directories to access data pertinent to this collection) and the link should run through URS." + ','
        except:
            result += 'np' + ', '
        # ================
        try:
           # print metadata['OnlineAccessURLs']['OnlineAccessURL']
            result += self.checkerRules.checkOnlineURLDesc(metadata['OnlineAccessURLs']['OnlineAccessURL']['URLDescription'], 1) + ', ,'
        except TypeError:
            if metadata['OnlineAccessURLs'] != None:
                length = len(metadata['OnlineAccessURLs']['OnlineAccessURL'])
                result += self.checkerRules.checkOnlineURLDesc(metadata['OnlineAccessURLs']['OnlineAccessURL'], length) + ', ,'
            else:
                result += 'Recommend providing descriptions for all Online Access URLs.' + ', , '
        except KeyError:
            result += 'Recommend providing descriptions for all Online Access URLs.' + ', ,'
        except:
            result += 'np' + ', ,'
        # ================
        try:
            result += self.checkerRules.checkOnlineResourceURL(metadata['OnlineResources']['OnlineResource']['URL'], 1) + ','
        except TypeError:
            if metadata['OnlineResources'] != None:
                length = len(metadata['OnlineResources']['OnlineResource'])
                result += self.checkerRules.checkOnlineResourceURL(metadata['OnlineResources']['OnlineResource'], length) + ','
            else:
                result += 'np' + ','
        except KeyError:
            result += 'np' + ','
        except:
            result += 'np' + ', '
        # ================
        try:
            result += self.checkerRules.checkOnlineResourceURLDesc(metadata['OnlineResources']['OnlineResource']['Description'], 1) + ','
        except TypeError:
            try:
                if metadata['OnlineResources'] != None:
                    length = len(metadata['OnlineResources']['OnlineResource'])
                    result += self.checkerRules.checkOnlineResourceURLDesc(metadata['OnlineResources']['OnlineResource'], length) + ','
                else:
                    result += 'np' + ','
            except:
                result += 'np' + ','
        except KeyError:
            result += 'np' + ','
        except:
            result += 'np' + ', '
        # ================
        try:
            result += self.checkerRules.checkOnlineResourceType(metadata['OnlineResources']['OnlineResource']['Type'], 1) + ', , , , ,'
        except TypeError:
            try:
                if metadata['OnlineResources'] != None:
                    length = len(metadata['OnlineResources']['OnlineResource'])
                    result += self.checkerRules.checkOnlineResourceType(metadata['OnlineResources']['OnlineResource'], length) + ', , , , ,'
                else:
                    result += 'np' + ', , , ,,'
            except:
                result += 'np' + ',,,,,'
        except KeyError:
            result += 'np' + ', , ,,,'
        except:
            result += 'np' + ',,,,,'

        try:
            result += self.checkerRules.checkSpatialCorordinateSystem(metadata['Spatial']['HorizontalSpatialDomain']['Geometry']['CoordinateSystem']) + ','
        except:
            result += 'This field is required in CMR. Provide one of the following values for coordinate system: CARTESIAN; GEODETIC' + ','
        result += ",,"
        # ================
        # result += self.checkSpatialHorGeoCoor(metadata['Spatial']['HorizontalSpatialDomain']['Geometry']['CoordinateSystem']) + ', '
        # ================
        try:
            result += self.checkerRules.checkBoundingRectangle(metadata['Spatial']['HorizontalSpatialDomain']['Geometry']['BoundingRectangle']) + ', , , , , , , , '
        except:
            result += 'np' + ', , , , , , , ,'
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
        result += ',,,,,,,,,,,'
        try:
            result += self.checkerRules.checkSpatialGranuleRepresent(metadata['Spatial']['GranuleSpatialRepresentation']) + ', ' * 17
        except:
            result += 'np' + ', ' * 17


        result += self.checkerRules.checkFieldNoneEmpty(metadata,
                                                        "SpatialInfo/HorizontalCoordinateSystem/GeodeticModel/HorizontalDatumName",
                                                        "OK - quality check",
                                                        "Recommend providing information about the datum if possible.")

        return result
