import csv
import urllib2

class parseInstrument():

    def __init__(self):
        ResourcesTypeURL = "https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/instruments?format=csv"
        response = urllib2.urlopen(ResourcesTypeURL)
        data = csv.reader(response)
        self.Class_ = []
        self.Type = []
        self.Category = []
        self.Subtype = []
        self.shortName = []
        self.longName = []
        self.UUID = []

        line_num = 0
        for res in data:
            if(line_num > 1):
                self.Category.append(res[0].strip(" \""))
                self.Class_.append(res[1].strip(" \""))
                self.Type.append(res[2].strip(" \""))
                self.Subtype.append(res[3].strip(" \""))
                self.shortName.append(res[4].strip(" \""))
                self.longName.append(res[5].strip(" \""))
                self.UUID.append(res[6].strip(" \"\n"))
            line_num += 1

    def getColumn(self,val):
        if(val == "" or val == None):
            return None
        if(val in self.Category):
            return 'Category'
        if(val in self.Class_):
            return 'Class'
        if (val in self.Type):
            return 'Type'
        if (val in self.Subtype):
            return 'Subtype'
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
    x = parseInstrument()
    print x.getColumn("NOT APPLICABLE")