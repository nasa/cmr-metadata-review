import csv
import urllib2
import Constants

class parseProjects():

    def __init__(self):
        ResourcesTypeURL = "https://gcmdservices.gsfc.nasa.gov/static/kms/projects/projects.csv"
        response = urllib2.urlopen(ResourcesTypeURL, timeout=Constants.TIMEOUT)
        data = csv.reader(response)

        self.Bucket = []
        self.shortName = []
        self.longName = []
        self.UUID = []

        line_num = 0
        for res in data:
            if(line_num > 1):
                self.Bucket.append(res[0].strip(" \""))
                self.shortName.append(res[1].strip(" \""))
                self.longName.append(res[2].strip(" \""))
                self.UUID.append(res[3].strip(" \"\n"))
            line_num += 1

    def getColumn(self,val):
        if(val == "" or val == None):
            return None
        if(val in self.Bucket):
            return 'Bucket'
        if(val in self.shortName):
            return 'Short_Name'
        if(val in self.longName):
            return 'Long_Name'
        if (val in self.UUID):
            return 'UUID'
        return None

    def getShortName(self,val):
        if(val in self.shortName):
            return True
        return False

    def getLongName(self,val):
        if(val in self.longName):
            return True
        return False

if __name__ == "__main__":
    x = parseProjects()
    print x.getColumn("AAWS")