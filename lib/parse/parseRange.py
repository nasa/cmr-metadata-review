import csv
import urllib2

class parseRange():

    def __init__(self):
        ResourcesTypeURL = "https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/temporalresolutionrange?format=csv"
        response = urllib2.urlopen(ResourcesTypeURL)
        data = csv.reader(response)

        self.Temporal_Resolution_Range = []
        self.UUID = []

        line_num = 0
        for res in data:
            if(line_num > 1):
                self.Temporal_Resolution_Range.append(res[0].strip(" \""))
                self.UUID.append(res[1].strip(" \"\n"))
            line_num += 1

    def getColumn(self,val):
        if(val == "" or val == None):
            return None
        if(val in self.Temporal_Resolution_Range):
            return 'Vertical_Resolution_Range'
        if(val in self.UUID):
            return 'UUID'
        return None

    def getTemporal_Resolution_Range(self,val):
        if(val in self.Temporal_Resolution_Range):
            return True
        return False

if __name__ == "__main__":
    x = parseRange()
    print x.getColumn("NOT APPLICABLE")