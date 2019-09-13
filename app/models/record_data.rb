#  A polymorphic ActiveRecord class used to store various types of data for a record review.    
#  RecordData will always be an attribute of a Datable class.    
#  RecordData will then store data in its rawJSON field.     
#  The rawJSON field is a string field storing JSON.     
#  The JSON will have a format of {"parentRecordField1": "polymorphicData", "parentRecordField2": "polymorphicData2",}     
#  So all of the keys will match the fields of the related record, and the data will vary depending on the direct parent (flags, opionions, colors, etc)      
#  This way data of a similar type can be saved for all fields of a record in one object, RecordData.

class RecordData < ApplicationRecord
  belongs_to :record
end