import csv
import urllib2
import Constants

class parseVerti():

    def __init__(self):
        ResourcesTypeURL = "https://gcmdservices.gsfc.nasa.gov/static/kms/verticalresolutionrange/verticalresolutionrange.csv?ed_wiki_keywords_page"

        response = urllib2.urlopen(ResourcesTypeURL, timeout=Constant.TIMEOUT)
        data = csv.reader(response)

        self.Vertical_Resolution_Range = []
        self.UUID = []

        line_num = 0
        for res in data:
            if(line_num > 1):
                self.Vertical_Resolution_Range.append(res[0].strip(" \""))
                self.UUID.append(res[1].strip(" \"\n"))
            line_num += 1

    def getColumn(self,val):
        if(val == "" or val == None):
            return None
        if(val in self.Vertical_Resolution_Range):
            return 'Vertical_Resolution_Range'
        if(val in self.UUID):
            return 'UUID'
        return None

    def getVertical_Resolution_Range(self,val):
        if(val in self.Vertical_Resolution_Range):
            return True
        return False

if __name__ == "__main__":
    x = parseVerti()
    print x.getColumn("NOT APPLICABLE")