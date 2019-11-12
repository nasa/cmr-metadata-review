import csv
import urllib2
import socket
from datetime import *
import Constants

PlatformURL = "https://gcmdservices.gsfc.nasa.gov/static/kms/platforms/platforms.csv"
InstrumentURL = "https://gcmdservices.gsfc.nasa.gov/static/kms/instruments/instruments.csv"
ProjectURL = "https://gcmdservices.gsfc.nasa.gov/static/kms/projects/projects.csv"
ResourcesTypeURL = "https://gcmdservices.gsfc.nasa.gov/static/kms/rucontenttype/rucontenttype.csv"

class checkerRules():

    def checkGranuleUR(self, val):
        #print "Input of checkGranuleUR() is " + val
        if val == None:
            return "Provide a granule UR for this granule. This is a required field."
        else:
            return "OK"

    def checkInsertTime(self, val):
        #print "Input of checkInsertTime() is " + val
        try:
            if val == None:
                return "np"
            if not val.endswith("Z"):
                return "InsertTime error."
            val = val.replace("Z", "")
            t_record = datetime.strptime(val, '%Y-%m-%dT%H:%M:%S')
            if t_record.microsecond / 1000 > 999:
                return "InsertTime error."
            t_now = datetime.now()
            if t_record.year > t_now.year:
                return "InsertTime error."
            return "OK"
        except ValueError:
            return "InsertTime error."

    def checkLastUpdate(self, updateTime, prodTime):
        #print "Input of checkLastUpdate() is " + updateTime + ', ' + prodTime
        try:
            if updateTime == None:
                return "np"
            elif not updateTime.endswith("Z"):
                return "LastUpdate time error."
            updateTime = updateTime.replace("Z", "")
            t_record = datetime.strptime(updateTime, '%Y-%m-%dT%H:%M:%S')
            prodTime = prodTime.replace("Z", "")
            p_record = datetime.strptime(prodTime, '%Y-%m-%dT%H:%M:%S')
            if t_record.microsecond / 1000 > 999:
                return "LastUpdate time error."
            t_now = datetime.now()
            if t_record.year > t_now.year or t_record < p_record:
                return "LastUpdate time error."
            return "OK"
        except ValueError:
            return "LastUpdate time error."

    def checkDeleteTime(self, deleteTime, prodTime):
        #print "Input of checkDeleteTime() is " + deleteTime + ', ' + prodTime
        try:
            if deleteTime == None:
                return "np"
            elif not deleteTime.endswith("Z"):
                return "Delete time error"
            deleteTime = deleteTime.replace("Z", "")
            t_record = datetime.strptime(deleteTime, '%Y-%m-%dT%H:%M:%S')
            prodTime = prodTime.replace("Z", "")
            p_record = datetime.strptime(prodTime, '%Y-%m-%dT%H:%M:%S')
            if t_record.microsecond / 1000 > 999:
                return "Delete time error"
            if p_record > t_record:
                return "Delete time error"
            return "OK - quality check"
        except ValueError:
            return "Delete time error"

    def checkCollectionShortName(self, sname):
        #print "Input of checkCollectionShortName() is " + sname
        if sname == None:
            return "np - Ensure the DataSetId field is provided."
        else:
            return "OK"

    def checkCollectionVersionID(self, sname):

        #print "Input of checkCollectionVersionID() is " + sname
        if sname == None:
            return "np - Ensure the DataSetId field is provided."
        else:
            return "OK"

    def checkDataSetId(set, val):
        #print "Input of checkDataSetId() is " + val
        if val == None:
            return "np - Ensure that the ShortName and VersionId fields are provided."
        elif val.isupper() or val.islower():
            return "Recommend that the Dataset Id use mixed case to optimize human readability."
        else:
            return "OK"

    def checkSizeMBDataGranule(set, val):
        #print "Input of checkSizeMBDataGranule() is " + val
        if val == None:
            return "Granule file size not provided. Recommend providing a value for this field in the metadata."
        else:
            return "OK - quality check"

    def checkDayNightFlag(set, val):
        #print "Input of checkDayNightFlag() is " + val
        DNFlags = ('DAY', 'NIGHT', 'BOTH', 'UNSPECIFIED')
        if val == None:
            return "np"
        elif val.upper() not in DNFlags:
            return "Invalid value for DayNightFlag. Valid values include: DAY; NIGHT; BOTH; UNSPECIFIED"
        else:
            return "OK"

    def checkProductionDateTime(self, prodTime, insertTime):
        #print "Input of checkProductionDateTime() is " + prodTime + ', ' + insertTime
        try:
            if prodTime == None:
                return "np"
            if not prodTime.endswith("Z"):
                return "ProductionDateTime error"
            prodTime = prodTime.replace("Z", "")
            p_record = datetime.strptime(prodTime, '%Y-%m-%dT%H:%M:%S')
            insertTime = insertTime.replace("Z", "")
            i_record = datetime.strptime(insertTime, '%Y-%m-%dT%H:%M:%S')
            if p_record.microsecond / 1000 > 999:
                return "ProductionDateTime error"
            t_now = datetime.now()
            if p_record > t_now:
                return "ProductionDateTime error"
            elif p_record != i_record:
                return "Format OK - does not match the InsertTime"
            return "OK"
        except ValueError:
            return "ProductionDateTime error"

    def checkTemporalSingleTime(self, val):
        #print "Input of checkTemporalSingleTime() is " + val
        try:
            if val == None:
                return "np"
            if not val.endswith("Z"):
                return "SingleDateTime error"
            val = val.replace("Z", "")
            t_record = datetime.strptime(val, '%Y-%m-%dT%H:%M:%S')
            if t_record.microsecond / 1000 > 999:
                return "SingleDateTime error"
            t_now = datetime.now()
            if t_record.year > t_now.year:
                return "SingleDateTime error"
            return "OK - quality check"
        except ValueError:
            return "SingleDateTime error"

    def checkTemporalBeginningTime(self, val):
        #print "Input of checkTemporalBeginningTime() is " + val
        try:
            if val == None:
                return "np"
            if not val.endswith("Z"):
                return "BeginningDateTime error"
            val = val.replace("Z", "")
            t_record = datetime.strptime(val, '%Y-%m-%dT%H:%M:%S')
            if t_record.microsecond / 1000 > 999:
                return "BeginningDateTime error"
            t_now = datetime.now()
            if t_record.year > t_now.year:
                return "BeginningDateTime error"
            return "OK - quality check"
        except ValueError:
            return "BeginningDateTime error"

    def checkTemporalEndingTime(self, val):
        #print "Input of checkTemporalEndingTime() is " + val
        try:
            if val == None:
                return "np"
            if not val.endswith("Z"):
                return "EndingDateTime error"
            val = val.replace("Z", "")
            t_record = datetime.strptime(val, '%Y-%m-%dT%H:%M:%S')
            if t_record.microsecond / 1000 > 999:
                return "EndingDateTime error"
            t_now = datetime.now()
            if t_record.year > t_now.year:
                return "EndingDateTime error"
            return "OK - quality check"
        except ValueError:
            return "EndingDateTime error"

    def checkBoundingRectangle(self, val):
        #print "Input of checkBoundingRectangle() is ..."

        if val['WestBoundingCoordinate'] == None or val['NorthBoundingCoordinate'] == None or val[
            'EastBoundingCoordinate'] == None or val['SouthBoundingCoordinate'] == None:
            return "Check for other spatial identifiers (Point; GPolygon; or Line). A spatial extent identifier is required., " + \
                   "Check for other spatial identifiers (Point; GPolygon; or Line). A spatial extent identifier is required., " + \
                   "Check for other spatial identifiers (Point; GPolygon; or Line). A spatial extent identifier is required., " + \
                   "Check for other spatial identifiers (Point; GPolygon; or Line). A spatial extent identifier is required., "

        msg = ''
        if float(val['WestBoundingCoordinate']) >= -180 and float(val['WestBoundingCoordinate']) <= 180:
            if float(val['EastBoundingCoordinate']) > float(val['WestBoundingCoordinate']):
                msg += "OK - quality check, "
            else:
                msg += "The East and West Bounding Coordinates may have been switched., "
        else:
            msg += "The coordinate does not fall within a valid range., "
        if float(val['NorthBoundingCoordinate']) >= -90 and float(val['NorthBoundingCoordinate']) <= 90:
            if float(val['SouthBoundingCoordinate']) < float(val['NorthBoundingCoordinate']):
                msg += "OK - quality check, "
            else:
                msg += "The North and South Bounding Coordinates may have been switched., "
        else:
            msg += "The coordinate does not fall within a valid range., "
        if float(val['EastBoundingCoordinate']) >= -180 and float(val['EastBoundingCoordinate']) <= 180:
            if float(val['EastBoundingCoordinate']) > float(val['WestBoundingCoordinate']):
                msg += "OK - quality check, "
            else:
                msg += "The East and West Bounding Coordinates may have been switched., "
        else:
            msg += "The coordinate does not fall within a valid range., "
        if float(val['SouthBoundingCoordinate']) >= -90 and float(val['SouthBoundingCoordinate']) <= 90:
            if float(val['SouthBoundingCoordinate']) < float(val['NorthBoundingCoordinate']):
                msg += "OK - quality check, "
            else:
                msg += "The North and South Bounding Coordinates may have been switched., "
        else:
            msg += "The coordinate does not fall within a valid range., "

        return msg

    def checkEquatorCrossingTime(self, val, length):
        #print "Input of checkEquatorCrossingTime() is ..."
        if length == 1:
            try:
                if val == None:
                    return "np"
                if not val.endswith("Z"):
                    return "DateTime error"
                val = val.replace("Z", "")
                t_record = datetime.strptime(val, '%Y-%m-%dT%H:%M:%S')
                if t_record.microsecond / 1000 > 999:
                    return "DateTime error"
                t_now = datetime.now()
                if t_record.year > t_now.year:
                    return "DateTime error"
                return "OK - quality check"
            except ValueError:
                return "DateTime error"
        else:
            for i in range(0, length):
                try:
                    if val['EquatorCrossingDateTime'] == None:
                        return "np"
                    if not val['EquatorCrossingDateTime'].endswith("Z"):
                        return "DateTime error"
                    val['EquatorCrossingDateTime'] = val['EquatorCrossingDateTime'].replace("Z", "")
                    t_record = datetime.strptime(val['EquatorCrossingDateTime'], '%Y-%m-%dT%H:%M:%S')
                    if t_record.microsecond > 999:
                        return "DateTime error"
                    t_now = datetime.now()
                    if t_record.year > t_now.year:
                        return "DateTime error"
                    return "OK - quality check"
                except ValueError:
                    return "DateTime error"

    def checkPlatformShortName(self, val, length):
        #print "Input of checkPlatformShortName() is ..."
        PlatformKeys = list()
        PlatformLongNames = list()
        response = urllib2.urlopen(PlatformURL, timeout=Constants.TIMEOUT)
        data = csv.reader(response)
        next(data)  # Skip the first two line information
        next(data)
        for item in data:
            PlatformKeys += item[2:3]
            PlatformLongNames += item[3:4]
        PlatformKeys = list(set(PlatformKeys))
        PlatformLongNames = list(set(PlatformLongNames))
        response.close()

        if length == 1:
            if val == None:
                return "np"
            if val not in PlatformKeys:
                if val in PlatformLongNames:
                    return val + ": incorrect keyword order"
                else:
                    return "The keyword does not conform to GCMD"
        else:
            for i in range(0, length):
                if val[i]['ShortName'] == None:
                    return "np"
                if val[i]['ShortName'] not in PlatformKeys:
                    if val[i]['ShortName'] in PlatformLongNames:
                        return val[i]['ShortName'] + ": incorrect keyword order"
                    else:
                        return "The keyword does not conform to GCMD"
        return "OK - quality check"

    # def checkInstrShortName(self, val, platformNum):
    #     #print "Input of checkInstrShortName() is ..."
    #     processInstrCount = 0
    #     InstrumentKeys = list()
    #     InstrumentLongNames = list()
    #     response = urllib2.urlopen(InstrumentURL)
    #     data = csv.reader(response)
    #     next(data)  # Skip the first two line information
    #     next(data)
    #     for item in data:
    #         if len(item) != 0:
    #             InstrumentKeys += item[4:5]
    #             InstrumentLongNames += item[5:6]
    #     InstrumentKeys = list(set(InstrumentKeys))
    #     InstrumentLongNames = list(set(InstrumentLongNames))
    #     response.close()

    #     if platformNum == 1:
    #         try:
    #             if val['Instruments']['Instrument']['ShortName'] == None:
    #                 return "np"
    #             if not any(s.lower() == val['Instruments']['Instrument']['ShortName'].lower() for s in InstrumentKeys):
    #                 if val['Instruments']['Instrument']['ShortName'] in InstrumentLongNames:
    #                     return val['Instruments']['Instrument'][instr]['ShortName'] + ": incorrect keyword order"
    #                 else:
    #                     return "The keyword does not conform to GCMD"
    #             processInstrCount += 1
    #         except TypeError:
    #             instrNum = len(val['Instruments']['Instrument'])
    #             for instr in range(0, instrNum):
    #                 if val['Instruments']['Instrument'][instr]['ShortName'] == None:
    #                     return "np"
    #                 if not any(s.lower() == val['Instruments']['Instrument'][instr]['ShortName'].lower() for s in InstrumentKeys):
    #                     if val['Instruments']['Instrument'][instr]['ShortName'] in InstrumentLongNames:
    #                         return val['Instruments']['Instrument'][instr]['ShortName'] + ": incorrect keyword order"
    #                     else:
    #                         return "The keyword does not conform to GCMD"
    #                 processInstrCount += 1
    #         except KeyError:
    #             #print "Access Key Error!"
    #     else:
    #         for i in range(0, platformNum):
    #             try:
    #                 if val[i]['Instruments']['Instrument']['ShortName'] == None:
    #                     return "np"
    #                 if not any(s.lower() == val[i]['Instruments']['Instrument']['ShortName'].lower() for s in InstrumentKeys):
    #                     if val[i]['Instruments']['Instrument']['ShortName'] in InstrumentLongNames:
    #                         return val[i]['Instruments']['Instrument']['ShortName'] + ": incorrect keyword order"
    #                     else:
    #                         return "The keyword does not conform to GCMD"
    #                 processInstrCount += 1
    #             except TypeError:
    #                 instrNum = len(val[i]['Instruments']['Instrument'])
    #                 for instr in range(0, instrNum):
    #                     if val[i]['Instruments']['Instrument'][instr]['ShortName'] == None:
    #                         return "np"
    #                     if not any(s.lower() == val[i]['Instruments']['Instrument'][instr]['ShortName'].lower() for s in InstrumentKeys):
    #                         if val[i]['Instruments']['Instrument'][instr]['ShortName'] in InstrumentLongNames:
    #                             return val[i]['Instruments']['Instrument'][instr]['ShortName'] + ": incorrect keyword order"
    #                         else:
    #                             return "The keyword does not conform to GCMD"
    #                     processInstrCount += 1
    #             except KeyError:
    #                 continue
    #     if processInstrCount != 0:
    #         return "OK - quality check"
    #     else:
    #         return "np"

    def checkInstrShortName(self, val, platformNum, instruments):
        #print "Input of checkInstrShortName() is ..."
        processInstrCount = 0
        InstrumentKeys = instruments[4]
        SensorResult = ''

        if platformNum == 1:
            try:
                # -------
                try:
                    val['Instruments']['Instrument']['Sensors']['Sensor']
                    if val['Instruments']['Instrument']['Sensors']['Sensor']['ShortName'] == \
                            val['Instruments']['Instrument']['ShortName']:
                        SensorResult = "Same as Instrument/ShortName. Consider removing since this is redundant information."
                except TypeError:
                    sensor_len = len(val['Instruments']['Instrument']['Sensors'])
                    for s in range(sensor_len):
                        try:
                            if val['Instruments']['Instrument']['Sensors'][s]['Sensor']['ShortName'] == \
                                    val['Instruments']['Instrument']['ShortName']:
                                SensorResult = "Same as Instrument/ShortName. Consider removing since this is redundant information."
                                break
                        except KeyError:
                            continue
                except KeyError:
                    SensorResult = 'np'
                # if len(SensorResult) == 0:
                #     SensorResult = 'Recommend removing sensors from the metadata; since this field will be deprecated in the future.'
                # -------
                if val['Instruments']['Instrument']['ShortName'] == None:
                    return "np", SensorResult
                if not any(s.lower() == val['Instruments']['Instrument']['ShortName'].lower() for s in InstrumentKeys):
                    return "The keyword does not conform to GCMD.", SensorResult
                processInstrCount += 1
            except TypeError:
                instrNum = len(val['Instruments']['Instrument'])
                for instr in range(0, instrNum):
                    # -------
                    try:
                        val['Instruments']['Instrument'][instr]['Sensors']['Sensor']
                        if val['Instruments']['Instrument'][instr]['Sensors']['Sensor']['ShortName'] == \
                                val['Instruments']['Instrument'][instr]['ShortName']:
                            SensorResult = "Same as Instrument/ShortName. Consider removing since this is redundant information."
                    except TypeError:
                        sensor_len = len(val['Instruments']['Instrument'][instr]['Sensors'])
                        for s in range(sensor_len):
                            try:
                                if val['Instruments']['Instrument'][instr]['Sensors'][s]['Sensor']['ShortName'] == \
                                        val['Instruments']['Instrument'][instr]['ShortName']:
                                    SensorResult = "Same as Instrument/ShortName. Consider removing since this is redundant information."
                                    break
                            except KeyError:
                                continue
                    except KeyError:
                        SensorResult = "np"
                    # if len(SensorResult) == 0:
                    #     SensorResult = 'Recommend removing sensors from the metadata; since this field will be deprecated in the future.'
                    # -------
                    if val['Instruments']['Instrument'][instr]['ShortName'] == None:
                        return "np", SensorResult
                    if not any(s.lower() == val['Instruments']['Instrument'][instr]['ShortName'].lower() for s in
                               InstrumentKeys):
                        return "The keyword does not conform to GCMD.", SensorResult
                    processInstrCount += 1
            #except KeyError:
                #print "Access Key Error!"
        else:
            for i in range(0, platformNum):
                try:
                    # -------
                    try:
                        val[i]['Instruments']['Instrument']['Sensors']['Sensor']
                        if val[i]['Instruments']['Instrument']['Sensors']['Sensor']['ShortName'] == \
                                val[i]['Instruments']['Instrument']['ShortName']:
                            SensorResult = "Same as Instrument/ShortName. Consider removing since this is redundant information."
                    except TypeError:
                        sensor_len = len(val[i]['Instruments']['Instrument']['Sensors'])
                        for s in range(sensor_len):
                            try:
                                if val[i]['Instruments']['Instrument']['Sensors'][s]['Sensor']['ShortName'] == \
                                        val[i]['Instruments']['Instrument']['ShortName']:
                                    SensorResult = "Same as Instrument/ShortName. Consider removing since this is redundant information."
                                    break
                            except KeyError:
                                SensorResult = "np"
                                continue
                    except KeyError:
                        SensorResult = "np"
                    # if len(SensorResult) == 0:
                    #     SensorResult = 'Recommend removing sensors from the metadata; since this field will be deprecated in the future.'
                    # -------
                    if val[i]['Instruments']['Instrument']['ShortName'] == None:
                        return "np", SensorResult
                    if not any(s.lower() == val[i]['Instruments']['Instrument']['ShortName'].lower() for s in
                               InstrumentKeys):
                        return "The keyword does not conform to GCMD.", SensorResult
                    processInstrCount += 1
                except TypeError:
                    instrNum = len(val[i]['Instruments']['Instrument'])
                    for instr in range(0, instrNum):
                        # -------
                        try:
                            val[i]['Instruments']['Instrument'][instr]['Sensors']['Sensor']
                            if val[i]['Instruments']['Instrument'][instr]['Sensors']['Sensor']['ShortName'] == \
                                    val[i]['Instruments']['Instrument'][instr]['ShortName']:
                                SensorResult = "Same as Instrument/ShortName. Consider removing since this is redundant information."
                        except TypeError:
                            sensor_len = len(val[i]['Instruments']['Instrument'][instr]['Sensors'])
                            for s in range(sensor_len):
                                try:
                                    if val[i]['Instruments']['Instrument'][instr]['Sensors'][s]['Sensor'][
                                        'ShortName'] == val[i]['Instruments']['Instrument'][instr]['ShortName']:
                                        SensorResult = "Same as Instrument/ShortName. Consider removing since this is redundant information."
                                        break
                                except KeyError:
                                    continue
                        except KeyError:
                            SensorResult = "np"
                        # if len(SensorResult) == 0:
                        #     SensorResult = 'Recommend removing sensors from the metadata; since this field will be deprecated in the future.'
                        # -------
                        if val[i]['Instruments']['Instrument'][instr]['ShortName'] == None:
                            return "np", SensorResult
                        if not any(s.lower() == val[i]['Instruments']['Instrument'][instr]['ShortName'].lower() for s in
                                   InstrumentKeys):
                            return "The keyword does not conform to GCMD.", SensorResult
                        processInstrCount += 1
                except KeyError:
                    continue
        if processInstrCount != 0:
            return "OK- quality check", SensorResult
        else:
            return "np", SensorResult

    # def checkSensorShortName(self, val, platformNum):
    #     #print "Input of checkInstrShortName() is ..."
    #     processInstrCount = 0
    #     SensorShortNames = list()
    #     SensorLongNames = list()
    #     response = urllib2.urlopen(InstrumentURL)
    #     data = csv.reader(response)
    #     next(data)  # Skip the first two line information
    #     next(data)
    #     for item in data:
    #         if len(item) != 0:
    #             SensorShortNames += item[4:5]
    #             SensorLongNames += item[5:6]
    #     SensorShortNames = list(set(SensorShortNames))
    #     SensorLongNames = list(set(SensorLongNames))
    #     response.close()


    def checkCampaignShortName(self, val, campaignNum):
        #print "Input of checkCampaignShortName() is ..."
        CampaignKeys = list()
        CampaignLongNames = list()
        response = urllib2.urlopen(ProjectURL, timeout=Constants.TIMEOUT)
        data = csv.reader(response)
        next(data)  # Skip the first two line information
        next(data)
        for item in data:
            if len(item) != 0:
                CampaignKeys += item[1:2]
                CampaignLongNames += item[2:3]
        CampaignKeys = list(set(CampaignKeys))
        CampaignLongNames = list(set(CampaignLongNames))
        response.close()

        if campaignNum == 1:
            if val == None:
                return "np"
            elif val not in CampaignKeys:
                if val in CampaignLongNames:
                    return val + ": incorrect keyword order"
                else:
                    return "The keyword does not conform to GCMD."
            else:
                return "OK"
        else:
            for i in range(campaignNum):
                if val[i]['Campaign']['ShortName'] == None:
                    return "np"
                elif val[i]['Campaign']['ShortName'] not in CampaignKeys:
                    if val[i]['Campaign']['ShortName'] in CampaignLongNames:
                        return val[i]['Campaign']['ShortName'] + ": incorrect keyword order"
                    else:
                        return "The keyword does not conform to GCMD."
                else:
                    return "OK"

    def checkOnlineAccessURL(self, val, length):
        #print "Input of checkOnlineAccessURL() is ..."
        brokenURLcount = 0
        msg = ""

        if length == 1:
            if val == None:
                return "np"
            try:
                connection = urllib2.urlopen(val, timeout=Constants.TIMEOUT)
                if connection:
                    realURL = connection.geturl()
                    connection.close()
                    if not realURL.startswith('https://urs.') and not realURL.startswith('http://urs.'):
                        return "Please provide a link that allows for direct download of the granule via https. This link should run through URS."
            except (urllib2.HTTPError, urllib2.URLError) as e:
                return "The Online Access URL is a broken link"
        else:
            for i in range(0, length):
                if val[i]['URL'] == None:
                    return "np"
                try:
                    connection = urllib2.urlopen(val[i]['URL'], timeout=Constants.TIMEOUT)
                    if connection:
                        realURL = connection.geturl()
                        connection.close()
                        if not realURL.startswith('https://urs.') and not realURL.startswith('http://urs.'):
                            return "Please provide a link that allows for direct download of the granule via https. This link should run through URS."
                except (urllib2.HTTPError, urllib2.URLError, socket.timeout) as e:
                    msg += "Broken link: " + val[i]['URL'] + ";"
                    brokenURLcount += 1
        if brokenURLcount != 0:
            return msg
        else:
            return "OK"

    def checkOnlineAccessURLDesc(self, val, length):
        #print "Input of checkOnlineAccessURLDesc() is ..."

        if length == 1:
            if val == None:
                return "Recommend providing a description for each Online Access URL."
        else:
            for i in range(0, length):
                if val[i].get('URLDescription') == None:
                    return "Recommend providing a description for each Online Access URL."
        return "OK - quality check"

    def checkOnlineResourceURL(self, val, length):
        #print "Input of checkOnlineResourceURL() is ..."
        brokenURLcount = 0
        msg = ""
        if length == 1:
            if val == None:
                return "np"
            try:
                connection = urllib2.urlopen(val, timeout=5)
                if connection:
                    connection.close()
            except (urllib2.HTTPError, urllib2.URLError, socket.timeout) as e:
                return "Broken link: " + val
        else:
            for i in range(0, length):
                try:
                    if val[i]['URL'] == None:
                        return "np"
                    connection = urllib2.urlopen(val[i]['URL'], timeout=5)
                    if connection:
                        connection.close()
                except (urllib2.HTTPError, urllib2.URLError, socket.timeout) as e:
                    msg += "Broken link: " + val[i]['URL'] + ";"
                    brokenURLcount += 1
        if brokenURLcount != 0:
            return msg
        else:
            return "OK"

    def checkOnlineResourceDesc(self, val, length):
        #print "Input of checkOnlineResourceDesc() is ..."
        if length == 1:
            if val == None:
                return "np"
            else:
                return "OK - quality check"
        else:
            flag = False
            flag1 = False
            for i in range(0, length):
                try:
                    if val[i]["Description"] != None:
                        flag = True
                    else:
                        flag1 = True
                except KeyError:
                    flag1 = True
            if (flag and flag1):
                return "Recommend providing a description for each Online Access URL."
            elif (flag and not flag1):
                return "OK - quality check"
            else:
                return "np"

    def checkOnlineResourceType(self, val, length):
        #print "Input of checkOnlineResourceType() is ..."
        ResourcesTypes = list()
        response = urllib2.urlopen(ResourcesTypeURL, timeout=Constants.TIMEOUT)
        data = csv.reader(response)
        next(data)  # Skip the first two row information
        next(data)
        for item in data:
            ResourcesTypes += item[0:1]
        ResourcesTypes = list(set(ResourcesTypes))
        response.close()
        listA = ["THREDDS CATALOG", "THREDDS DATA", "THREDDS DIRECTORY", "GET WEB MAP FOR TIME SERIES",
                 "GET RELATED VISUALIZATION", "GIOVANNI", "WORLDVIEW", "GET MAP SERVICE"]
        listB = ["GET WEB MAP SERVICE (WMS)", "GET WEB COVERAGE SERVICE (WCS)", "OPENDAP DATA (DODS)"]
        result = ""
        if length == 1:
            if val == None:
                return "Provide a URL Type for all Online Resource URLs. Choose a type from the following list: https://gcmdservices.gsfc.nasa.gov/static/kms/rucontenttype/rucontenttype.csv;"
            elif val not in ResourcesTypes:
                return "Invalid types: " + val + " URL Types are translated to GCMD vocabulary in CMR. In order to avoid translation errors; please choose an appropriate URL Content Type from the following keywords list: https://gcmdservices.gsfc.nasa.gov/static/kms/rucontenttype/rucontenttype.csv;"
        else:
            for i in range(0, length):
                try:
                    if val[i]['URL'] != None:
                        try:
                            if val[i]['Type'] == None:
                                result += "Provide a URL Type for all Online Resource URLs. Choose a type from the following list: https://gcmdservices.gsfc.nasa.gov/static/kms/rucontenttype/rucontenttype.csv"
                                result += ";"
                            elif val[i]['Type'] not in ResourcesTypes:
                                result += "Invalid types: " + val[i][
                                    'Type'] + " URL Types are translated to GCMD vocabulary in CMR. In order to avoid translation errors; please choose an appropriate URL Content Type from the following keywords list: https://gcmdservices.gsfc.nasa.gov/static/kms/rucontenttype/rucontenttype.csv"
                                result += ";"
                            elif (val[i]['Type'] in listA):
                                result += "OK - one point for data accessability score for providing an advanced service for visualization;subsetting or aggregation;"
                            elif (val[i]['Type'] in listB):
                                result += "OK - two points for data accessability score for providing an advanced service for visualization; subsetting or aggregation which also meets common framework requirements for standard API based data access;"
                            else:
                                result += "OK;"
                        except KeyError:
                            return "np;"
                except KeyError:
                    result += "np;"
                    continue
        return result

    def checkOrderable(self, val):
        #print "Input of checkOrderable() is " + val
        if val == None:
            return "np"
        else:
            return "Note: The Orderable field is being deprecated in UMM."

    def checkDataFormat(self, val):
        #print "Input of checkDataFormat() is " + val
        if val == None:
            return "Recommend providing the data format(s) for this dataset"
        else:
            return "OK " + val

    def checkVisible(self, val):
        #print "Input of checkVisible() is " + val
        if val == None:
            return "np"
        else:
            return "Note: The Visible field is being deprecated in UMM."