import csv
import urllib2

class parsePlatform():

    def __init__(self):
        ResourcesTypeURL = "https://gcmdservices.gsfc.nasa.gov/static/kms/platforms/platforms.csv"
        response = urllib2.urlopen(ResourcesTypeURL)
        data = csv.reader(response)

        self.entity = []
        self.shortName = []
        self.Category = []
        self.longName = []
        self.UUID = []

        line_num = 0
        for res in data:
            if(line_num > 1):
                self.Category.append(res[0].strip(" \""))
                self.entity.append(res[1].strip(" \""))
                self.shortName.append(res[2].strip(" \""))
                self.longName.append(res[3].strip(" \""))
                self.UUID.append(res[4].strip(" \"\n"))
            line_num += 1

    def getColumn(self,val):
        if(val == "" or val == None):
            return None
        if(val in self.Category):
            return 'Category'
        if(val in self.entity):
            return 'Series_Entity'
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
    def getCategory(self,val):
        if(val in self.Category):
            return True
        return False
if __name__ == "__main__":
    x = parsePlatform()
    print x.getColumn("Douglas DC-6")