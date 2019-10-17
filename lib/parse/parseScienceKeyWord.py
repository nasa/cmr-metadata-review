import csv
import urllib2

class parseScienceKeyWord():

    def __init__(self):

        ResourcesTypeURL = "https://gcmdservices.gsfc.nasa.gov/static/kms/sciencekeywords/sciencekeywords.csv"
        response = urllib2.urlopen(ResourcesTypeURL, timeout=5)
        f = csv.reader(response)

        self.Topic = []
        self.Term = []
        self.Category = []
        self.Variable_Level_1 = []
        self.Variable_Level_2 = []
        self.Variable_Level_3 = []
        self.Detailed_Variable = []
        self.UUID = []

        line_num = 0
        for res in f:
            if(line_num > 1):
                self.Category.append(res[0].strip(" \""))
                self.Topic.append(res[1].strip(" \""))
                self.Term.append(res[2].strip(" \""))
                self.Variable_Level_1.append(res[3].strip(" \""))
                self.Variable_Level_2.append(res[4].strip(" \""))
                self.Variable_Level_3.append(res[5].strip(" \""))
                self.Detailed_Variable.append(res[6].strip(" \""))
                self.UUID.append(res[7][1:-2])
            line_num += 1

    def getColumn(self,val):
        if (val == "" or val == None):
            return None
        if(val in self.Category):
            return 'Category'
        if(val in self.Topic):
            return 'Topic'
        if(val in self.Term):
            return 'Term'
        if(val in self.Variable_Level_1):
            return 'Variable_Level_1'
        if (val in self.Variable_Level_2):
            return 'Variable_Level_2'
        if (val in self.Variable_Level_3):
            return 'Variable_Level_3'
        if (val in self.Detailed_Variable):
            return 'Detailed_Variable'
        if (val in self.UUID):
            return 'UUID'
        return None
    def getVariable_Level_1(self,val):
        if(val in self.Variable_Level_1):
            return True
        return False
    def getVariable_Level_2(self,val):
        if(val in self.Variable_Level_2):
            return True
        return False
    def getVariable_Level_3(self,val):
        if(val in self.Variable_Level_3):
            return True
        return False
    def getTerm(self,val):
        if(val in self.Term):
            return True
        return False
    def getTopic(self,val):
        if(val in self.Topic):
            return True
        return False
    def getCategory(self,val):
        if(val in self.Category):
            return True
        return False

if __name__ == "__main__":
    x = parseScienceKeyWord()
    print x.getColumn("EARTH SCIENCE")