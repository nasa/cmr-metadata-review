module UmmcToIsoMendsHelper
  def getISOMendsFieldMapping(ummJsonField)
    value = ISO_MENDS_FIELD_MAPPINGS[ummJsonField]
    if value.blank?
      value = 'No field mapping found.'
    end

    if value.sub(' ', '').start_with? '[=>', '[==>'
      pos = ummJsonField.index('/')
      unless pos.nil?
        parent_field = ummJsonField[0...pos]
        parent_value = ISO_MENDS_FIELD_MAPPINGS[parent_field]
        value = parent_value + "
        " + value
      end
    end
    value
  end
  ISO_MENDS_FIELD_MAPPINGS = {
      "MetadataLanguage" => "/gmi:MI_Metadata/gmd:language/gco:CharacterString
with
/gmi:MI_Metadata/gmd:MD_CharacterSetCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode\" codeListValue=\"utf8\"",
      "MetadataDates/Date" => "/gmi:MI_Metadata/datestamp (write only) use update date if it exists otherwise use creation date if it exists, otherwise use current date.
/gmi:MI_Metadata/gmd:metadataExtensionInfo/gmd:MD_MetadataExtensionInformation/gmd:extendedElementInformation/gmd:MD_ExtendedElementInformation/
[=>gmd:name/gco:CharacterString=Metadata Create Date
[=>gmd:definition/gco:CharacterString=Create Date
[=>gmd:dataType/gmd:MD_DatatypeCode codeList=\"\" codeListValue=\"\" = Date
[=>gmd:domainValue/gco:CharacterString= {the actual date}
[=>gmd:parentEntity gco:nilReason=\"inapplicable\"
[=>gmd:rule gco:nilReason=\"inapplicable\"
[=>gmd:source gco:nilReason=\"inapplicable\"",
      "MetadataDates/Type" => '/gmi:MI_Metadata/datestamp (write only) use update date if it exists otherwise use creation date if it exists, otherwise use current date.
CREATE
/gmi:MI_Metadata/gmd:metadataExtensionInfo/gmd:MD_MetadataExtensionInformation/gmd:extendedElementInformation/gmd:MD_ExtendedElementInformation/\=>
\=>gmd:name/gco:CharacterString=Metadata Create Date
\=>gmd:definition/gco:CharacterString=Create Date
\=>gmd:dataType/gmd:MD_DatatypeCode codeList="" codeListValue="" = Date
\=>gmd:domainValue/gco:CharacterString= {the actual date}
\=>gmd:parentEntity gco:nilReason="inapplicable"
\=>gmd:rule gco:nilReason="inapplicable"
\=>gmd:source gco:nilReason="inapplicable"

UPDATE
/gmi:MI_Metadata/gmd:metadataExtensionInfo/gmd:MD_MetadataExtensionInformation/gmd:extendedElementInformation/gmd:MD_ExtendedElementInformation/\=>
\=>gmd:name/gco:CharacterString=Metadata Update Date
\=>gmd:definition/gco:CharacterString=Update Date
\=>gmd:dataType/gmd:MD_DatatypeCode codeList="" codeListValue="" = Date
\=>gmd:domainValue/gco:CharacterString= {the actual date}
\=>gmd:parentEntity gco:nilReason="inapplicable"
\=>gmd:rule gco:nilReason="inapplicable"
\=>gmd:source gco:nilReason="inapplicable"

REVIEW
/gmi:MI_Metadata/gmd:metadataExtensionInfo/gmd:MD_MetadataExtensionInformation/gmd:extendedElementInformation/gmd:MD_ExtendedElementInformation/\=>
\=>gmd:name/gco:CharacterString=Metadata Future Review Date
\=>gmd:definition/gco:CharacterString=Future Review Date
\=>gmd:dataType/gmd:MD_DatatypeCode codeList="" codeListValue="" = Date
\=>gmd:domainValue/gco:CharacterString= {the actual date}
\=>gmd:parentEntity gco:nilReason="inapplicable"
\=>gmd:rule gco:nilReason="inapplicable"
\=>gmd:source gco:nilReason="inapplicable"

DELETE
/gmi:MI_Metadata/gmd:metadataExtensionInfo/gmd:MD_MetadataExtensionInformation/gmd:extendedElementInformation/gmd:MD_ExtendedElementInformation/\=>
\=>gmd:name/gco:CharacterString=Metadata Delete Date
\=>gmd:definition/gco:CharacterString=Delete Date
\=>gmd:dataType/gmd:MD_DatatypeCode codeList="" codeListValue="" = Date
\=>gmd:domainValue/gco:CharacterString= {the actual date}
\=>gmd:parentEntity gco:nilReason="inapplicable"
\=>gmd:rule gco:nilReason="inapplicable"
\=>gmd:source gco:nilReason="inapplicable"
',
      "ShortName" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/ [=>
[=> gmd:code/gco:CharacterString
and
[=> gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.shortname
and
[=> gmd:description/gco:CharacterString = Short Name
(CMR read only) If the gmd:code/gco:CharacterString doesn't exist look at gmd:code/gmx:Anchor.",
      "Version" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:edition/gco:CharacterString",
      "VersionDescription" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:otherCitationDetails/gco:CharacterString \"Version Description: …..\"",
      "EntryTitle" => "write only:
/gmi:MI_Metadata/gmd:fileIdentifier/gco:CharacterString
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString",
      "DOI" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/ [=>
[=> gmd:code/gco:CharacterString
and
[=> gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.doi
and
[=> gmd:description/gco:CharacterString contains DOI",
      "DOI/Authority" => "[=>gmd:authority/gmd:CI_Citation/gmd:title - empty element
and
[=> gmd:authority/gmd:CI_Citation/gmd:date - empty element
and
[=>gmd:authority/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString
and
[=>gmd:authority/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#CI_RoleCode\" codeListValue=\"\"  = authority",
      "DOI/DOI" => "[=> gmd:code/gco:CharacterString
and
[=> gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.doi
and
[=> gmd:description/gco:CharacterString contains DOI",
      "DOI/MissingReason" => "[=> gmd:code nilReason=\"inapplicable\"
and
[=> gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.doi
and
[=> gmd:description/gco:CharacterString contains DOI",
      "DOI/Explanation" => "[=>  gmd:description/gco:CharacterString contains Explanation:",
      "Abstract" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract/gco:CharacterString",
      "Purpose" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:purpose/gco:CharacterString",
      "DataLanguage" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:language/gco:CharacterString
with
/gmi:MI_Metadata/ gmd:identificationInfo/gmd:MD_DataIdentification/ gmd:MD_CharacterSetCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode\"  codeListValue=UTF8",
      "DataDates/Date" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/gco:DateTime
with
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode   codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml codeListValue varies.",
      "DataCenters" => "UMM Roles - ISO Roles
ARCHIVER       - custodian
DISTRIBUTOR - distributor
ORIGINATOR  - originator
PROCESSOR    - processor
We will place all UMM DataCenters to DataIdentification pointOfContact - as originator,custodian, processor, and distributor.  We will also add distributor and processor into the distribution and processStep sections respectively.  We will only read from DataIdentification pointOfContact section for the Data Centers.

1) Read/write all roles:
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/

2) DISTRIBUTOR write only:
Read if DISTRIBUTOR role didn't exist in #1 above.
/gmi:MI_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/

3) PROCESSOR write only:
Read if PROCESSOR role didn't exist in #1 above.
/gmi:MI_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep/gmi:LE_ProcessStep/gmd:processor/gmd:CI_ResponsibleParty/

4) ARCHIVER write only:
Read if ARCHIVER doesn't exist in #1 above.
/gmi:MI_Metadata/gmd:contact/gmd:CI_ResponsibleParty/",
      "DataCenters/Roles" => "read/write:
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/[=>
write only if PROCESSOR exists above otherwise read from here:
/gmi:MI_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep/gmi:LE_ProcessStep/gmd:processor/[=>

[=>gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode = processor",
      "DataCenters/ShortName" => "[=>gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString  ShortName delimited by &gt; LongName - only if LongName exists.",
      "DataCenters/LongName" => "[=>gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString  ShortName delimited by &gt; LongName - only if LongName exists.",
      "DataCenters/ContactInformation/ServiceHours" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService/gco:CharacterString",
      "DataCenters/ContactInformation/ContactInstruction" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:contactInstructions/gco:CharacterString",
      "DataCenters/ContactInformation/ContactMechanisms/Value" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/[==>
[==>gmd:voice/gco:CharacterString (UMM Types=>ISO: Direct Line, Mobile, Primary, TDD/TTY Phone, Telephone, U.S. toll free, Other) (ISO=>UMM: Telephone) or gmd:facsimile/gco:CharacterString (Fax)
[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString",
      "DataCenters/ContactInformation/Addresses" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/",
      "DataCenters/ContactInformation/Addresses/StreetAddresses" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint/gco:CharacterString",
      "DataCenters/ContactInformation/Addresses/City" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city/gco:CharacterString",
      "DataCenters/ContactInformation/Addresses/StateProvince" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea/gco:CharacterString",
      "DataCenters/ContactInformation/Addresses/PostalCode" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode/gco:CharacterString",
      "DataCenters/ContactInformation/Addresses/Country" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country/gco:CharacterString",
      "DataCenters/ContactInformation/RelatedUrls" => "[=>gmd:CI_ResponsibleParty/gmd:onlineResource",
      "DataCenters/ContactInformation/RelatedUrls/Description" => "[=>gmd:CI_ResponsibleParty/gmd:onlineResource/gmd:CI_OnlineResource/gmd:description",
      "DataCenters/ContactInformation/RelatedUrls/URL" => "[=>gmd:CI_ResponsibleParty/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL",
      "DataCenters/ContactPersons" => "(For every ContactPerson except Metadata Author, create a new pointOfContact and add the Data Center Short Name and Long Name to the
[=>gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString
- this does not get translated to the write only DISTRIBUTOR or PROCESSOR. Metadata Authors are put into the /gmi:MI_Metadata/gmd:contact/gmd:CI_ResponsibleParty/ section.)",
      "DataCenters/ContactPersons/Roles" => "[=>gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode (for more than 1 role another pointOfContact must be created)",
      "DataCenters/ContactPersons/NonDataCenterAffiliation" => "[=>gmd:CI_ResponsibleParty/gmd:positionName/gco:CharacterString = NonDataCenterAffiliation:",
      "DataCenters/ContactPersons/FirstName" => "[=>gmd:CI_ResponsibleParty/gmd:individualName/gco:CharacterString = FirstName:",
      "DataCenters/ContactPersons/MiddleName" => "[=>gmd:CI_ResponsibleParty/gmd:individualName/gco:CharacterString = MiddleName:",
      "DataCenters/ContactPersons/LastName" => "[=>gmd:CI_ResponsibleParty/gmd:individualName/gco:CharacterString = LastName:",
      "DataCenters/ContactPersons/ContactInformation/ServiceHours" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService/gco:CharacterString",
      "DataCenters/ContactPersons/ContactInformation/ContactInstruction" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:contactInstructions/gco:CharacterString",
      "DataCenters/ContactPersons/ContactInformation/ContactMechanisms/Value" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/[==>
[==>gmd:voice/gco:CharacterString (UMM Types=>ISO: Direct Line, Mobile, Primary, TDD/TTY Phone, Telephone, U.S. toll free, Other) (ISO=>UMM: Telephone) or gmd:facsimile/gco:CharacterString (Fax)
[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString",
      "DataCenters/ContactPersons/ContactInformation/Addresses" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/",
      "DataCenters/ContactPersons/ContactInformation/Addresses/StreetAddresses" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint/gco:CharacterString",
      "DataCenters/ContactPersons/ContactInformation/Addresses/City" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city/gco:CharacterString",
      "DataCenters/ContactPersons/ContactInformation/Addresses/StateProvince" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea/gco:CharacterString",
      "DataCenters/ContactPersons/ContactInformation/Addresses/PostalCode" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode/gco:CharacterString",
      "DataCenters/ContactPersons/ContactInformation/Addresses/Country" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country/gco:CharacterString",
      "DataCenters/ContactPersons/ContactInformation/RelatedUrls" => "[=>gmd:CI_ResponsibleParty/gmd:onlineResource",
      "DataCenters/ContactPersons/ContactInformation/RelatedUrls/Description" => "[=>gmd:CI_ResponsibleParty/gmd:onlineResource/gmd:CI_OnlineResource/gmd:description",
      "DataCenters/ContactPersons/ContactInformation/RelatedUrls/URL" => "[=>gmd:CI_ResponsibleParty/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL",
      "DataCenters/ContactGroups" => "(For every ContactGroup create a new pointOfContact and add the Data Center Short Name and Long Name to the
[=>gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString
- this does not get translated to the write only DISTRIBUTOR or PROCESSOR.)",
      "DataCenters/ContactGroups/Roles" => "[=>gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode (for more than 1 role another pointOfContact must be created)",
      "DataCenters/ContactGroups/NonDataCenterAffiliation" => "[=>gmd:CI_ResponsibleParty/gmd:positionName/gco:CharacterString = NonDataCenterAffiliation:",
      "DataCenters/ContactGroups/GroupName" => "[=>gmd:CI_ResponsibleParty/gmd:individualName/gco:CharacterString = GroupName:",
      "DataCenters/ContactGroups/ContactInformation/ServiceHours" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService/gco:CharacterString",
      "DataCenters/ContactGroups/ContactInformation/ContactInstruction" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:contactInstructions/gco:CharacterString",
      "DataCenters/ContactGroups/ContactInformation/ContactMechanisms/Value" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/[==>
[==>gmd:voice/gco:CharacterString (UMM Types=>ISO: Direct Line, Mobile, Primary, TDD/TTY Phone, Telephone, U.S. toll free, Other) (ISO=>UMM: Telephone) or gmd:facsimile/gco:CharacterString (Fax)
[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString",
      "DataCenters/ContactGroups/ContactInformation/Addresses" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/",
      "DataCenters/ContactGroups/ContactInformation/Addresses/StreetAddresses" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint/gco:CharacterString",
      "DataCenters/ContactGroups/ContactInformation/Addresses/City" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city/gco:CharacterString",
      "DataCenters/ContactGroups/ContactInformation/Addresses/StateProvince" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea/gco:CharacterString",
      "DataCenters/ContactGroups/ContactInformation/Addresses/PostalCode" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode/gco:CharacterString",
      "DataCenters/ContactGroups/ContactInformation/Addresses/Country" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country/gco:CharacterString",
      "DataCenters/ContactGroups/ContactInformation/RelatedUrls" => "[=>gmd:CI_ResponsibleParty/gmd:onlineResource",
      "DataCenters/ContactGroups/ContactInformation/RelatedUrls/Description" => "[=>gmd:CI_ResponsibleParty/gmd:onlineResource/gmd:CI_OnlineResource/gmd:description",
      "DataCenters/ContactGroups/ContactInformation/RelatedUrls/URL" => "[=>gmd:CI_ResponsibleParty/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL",
      "ContactPersons" => "For all roles except Metadata Author:
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact[=>
For Metadata Author:
/gmi:MI_Metadata/gmd:contact[=>",
      "ContactPersons/Roles" => "[=>gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode (for more than 1 role another pointOfContact must be created)",
      "ContactPersons/NonDataCenterAffiliation" => "[=>gmd:CI_ResponsibleParty/gmd:positionName/gco:CharacterString = NonDataCenterAffiliation:",
      "ContactPersons/FirstName" => "[=>/gmd:CI_ResponsibleParty/gmd:individualName/gco:CharacterString = FirstName:",
      "ContactPersons/MiddleName" => "[=>gmd:CI_ResponsibleParty/gmd:individualName/gco:CharacterString = MiddleName:",
      "ContactPersons/LastName" => "[=>/gmd:CI_ResponsibleParty/gmd:individualName/gco:CharacterString = LastName:",
      "ContactPersons/ContactInformation/ServiceHours" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService/gco:CharacterString",
      "ContactPersons/ContactInformation/ContactInstruction" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:contactInstructions/gco:CharacterString",
      "ContactPersons/ContactInformation/ContactMechanisms/Value" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/[==>
[==>gmd:voice/gco:CharacterString (UMM Types=>ISO: Direct Line, Mobile, Primary, TDD/TTY Phone, Telephone, U.S. toll free, Other) (ISO=>UMM: Telephone) or gmd:facsimile/gco:CharacterString (Fax)
[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString",
      "ContactPersons/ContactInformation/Addresses" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/",
      "ContactPersons/ContactInformation/Addresses/StreetAddresses" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint/gco:CharacterString",
      "ContactPersons/ContactInformation/Addresses/City" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city/gco:CharacterString",
      "ContactPersons/ContactInformation/Addresses/StateProvince" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea/gco:CharacterString",
      "ContactPersons/ContactInformation/Addresses/PostalCode" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode/gco:CharacterString",
      "ContactPersons/ContactInformation/Addresses/Country" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country/gco:CharacterString",
      "ContactPersons/ContactInformation/RelatedUrls" => "[=>gmd:CI_ResponsibleParty/gmd:onlineResource",
      "ContactPersons/ContactInformation/RelatedUrls/Description" => "[=>gmd:CI_ResponsibleParty/gmd:onlineResource/gmd:CI_OnlineResource/gmd:description",
      "ContactPersons/ContactInformation/RelatedUrls/URL" => "[=>gmd:CI_ResponsibleParty/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL",
      "ContactGroups" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact[=>",
      "ContactGroups/Roles" => "[=>gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode (for more than 1 role another pointOfContact must be created)",
      "ContactGroups/NonDataCenterAffiliation" => "[=>gmd:CI_ResponsibleParty/gmd:positionName/gco:CharacterString = NonDataCenterAffiliation:",
      "ContactGroups/GroupName" => "[=>/gmd:CI_ResponsibleParty/gmd:individualName/gco:CharacterString = GroupName:",
      "ContactGroups/ContactInformation/ServiceHours" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService/gco:CharacterString",
      "ContactGroups/ContactInformation/ContactInstruction" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:contactInstructions/gco:CharacterString",
      "ContactGroups/ContactInformation/ContactMechanisms/Value" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/[==>
[==>gmd:voice/gco:CharacterString (UMM Types=>ISO: Direct Line, Mobile, Primary, TDD/TTY Phone, Telephone, U.S. toll free, Other) (ISO=>UMM: Telephone) or gmd:facsimile/gco:CharacterString (Fax)
[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString",
      "ContactGroups/ContactInformation/Addresses" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/",
      "ContactGroups/ContactInformation/Addresses/StreetAddresses" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint/gco:CharacterString",
      "ContactGroups/ContactInformation/Addresses/City" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city/gco:CharacterString",
      "ContactGroups/ContactInformation/Addresses/StateProvince" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea/gco:CharacterString",
      "ContactGroups/ContactInformation/Addresses/PostalCode" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode/gco:CharacterString",
      "ContactGroups/ContactInformation/Addresses/Country" => "[=>gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country/gco:CharacterString",
      "ContactGroups/ContactInformation/RelatedUrls" => "[=>gmd:CI_ResponsibleParty/gmd:onlineResource",
      "ContactGroups/ContactInformation/RelatedUrls/Description" => "[=>gmd:CI_ResponsibleParty/gmd:onlineResource/gmd:CI_OnlineResource/gmd:description",
      "ContactGroups/ContactInformation/RelatedUrls/URL" => "[=>gmd:CI_ResponsibleParty/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL",
      "CollectionDataType" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/[=>
[=> gmd:code/gco:CharacterString
and
[=>gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.collectiondatatype
and
[=> gmd:description/gco:CharacterString = Collection Data Type",
      "ProcessingLevel" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:processingLevel",
      "ProcessingLevel/Id" => "(read and write)
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:processingLevel/gmd:MD_Identifier/gmd:code/gco:CharacterString
and
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:processingLevel/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.processinglevelid
and (write only)
/gmi:MI_Metadata/gmd:contentInfo/gmd:MD_ImageDescription/gmd:processingLevelCode/gmd:MD_Identifier/gmd:code/gco:CharacterString
and
/gmi:MI_Metadata/gmd:contentInfo/gmd:MD_ImageDescription/gmd:processingLevelCode/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.processinglevelid",
      "ProcessingLevel/ProcessingLevelDescription" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:processingLevel/gmd:MD_Identifier/gmd:description/gco:CharacterString
and
/gmi:MI_Metadata/gmd:contentInfo/gmd:MD_ImageDescription/gmd:processingLevelCode/gmd:MD_Identifier/gmd:description/gco:CharacterString",
      "CollectionCitations" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation [=>",
      "CollectionCitations/Creator" => "(READ from both individualName and organistionName and concatenate - WRITE to individual name only since we don't know how to parse the data.
WRITE and READ - must NOT have positionName with the value of editor.)
[=>/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:individualName/gco:CharacterString and/or
[=>/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString with
[=>/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role/CI_RoleCode=author",
      "CollectionCitations/Editor" => "(READ from both individualName and organistionName and concatenate - WRITE to individual name only since we don't know how to parse the data.
WRITE and READ - must have positionName and the value must be editor where the role is author)
[=>/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:individualName/gco:CharacterString and/or
[=>/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString with
[=>/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:positionName/gco:CharacterString = editor
and
[=>/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role/CI_RoleCode=author",
      "CollectionCitations/Title" => "[=>/gmd:title/gco:CharacterString",
      "CollectionCitations/SeriesName" => "[=>/gmd:series/gmd:CI_Series/gmd:name/gco:CharacterString",
      "CollectionCitations/ReleaseDate" => "[=>/gmd:editionDate/gco:DateTime",
      "CollectionCitations/ReleasePlace" => "(READ - concatenate all elements of CI_Address
WRITE - if parsable parse into individual components if not then put all into deliveryPoint
READ and WRITE: must contain positionName and the value must be release place and the role must be publisher)
[=>/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty>/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address [==>
[==>/gmd:deliveryPoint
[==>/gmd:city/gco:CharacterString (0..1)
[==>/gmd:administrativeArea/gco:CharacterString (0..1)
[==>/gmd:postalCode/gco:CharacterString (0..1)
[==>/gmd:country/gco:CharacterString (0..1)
[==>/gmd:electronicMailAddress/gco:CharacterString (0..*)
with
[=>/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:positionName/gco:CharacterString = release place
and
[=>/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role/CI_RoleCode=publisher",
      "CollectionCitations/Publisher" => "(READ from both individualName and organistionName and concatenate - WRITE to individual name only since we don't know how to parse the data.
READ and WRITE: must NOT contain positionName with value of release place)
[=>/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:individualName/gco:CharacterString and/or
[=>/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString with
[=>/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role/CI_RoleCode=publisher",
      "CollectionCitations/Version" => "[=>/gmd:edition/gco:CharacterString",
      "CollectionCitations/IssueIdentification" => "[=>/gmd:series/gmd:CI_Series/gmd:issueIdentification/gco:CharacterString",
      "CollectionCitations/DataPresentationForm" => "[=>/gmd:presentationForm/gmd:CI_PresentationFormCode codeList=\"\" codeListValue=\"\"",
      "CollectionCitations/OtherCitationDetails" => "[=>/gmd:otherCitationDetails/gco:CharacterString \"Other Details: …..\"",
      "CollectionCitations/OnlineResource" => "[=>/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:onlineResource/gmd:CI_OnlineResource [===>
and
[=>/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#CI_RoleCode\" codeListValue=\"resourceProvider\"  = resourceProvider",
      "CollectionCitations/OnlineResource/Linkage" => "[===>/gmd:linkage/gmd:URL",
      "CollectionCitations/OnlineResource/Protocol" => "[===>/gmd:protocol/gco:CharacterString",
      "CollectionCitations/OnlineResource/ApplicationProfile" => "[===>/gmd:applicationProfile/gco:CharacterString",
      "CollectionCitations/OnlineResource/Name" => "[===>/gmd:name/gco:CharacterString",
      "CollectionCitations/OnlineResource/Description" => "[===>/gmd:description/gco:CharacterString",
      "CollectionCitations/OnlineResource/Function" => "[===>/gmd:function/gmd:CI_OnLineFunctionCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#CI_OnLineFunctionCode\" codeListValue=\"information\" = information",
      "CollectionProgress" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:status/gmd:MD_ProgressCode
with codeListValue attribute",
      "Quality" => "/gmi:MI_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_QuantitativeAttributeAccuracy/gmd:evaluationMethodDescription/gco:CharacterString",
      "UseConstraints" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation/gco:CharacterString",
      "UseConstraints/Description" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation/gco:CharacterString = \"Restriction Comment: \"",
      "UseConstraints/LicenseUrl" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useConstraints/gmd:MD_RestrictionCode codeList \"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_RestrictionCode\" codeListValue \"otherRestrictions\" =  \"otherRestrictions\"",
      "UseConstraints/LicenseUrl/Linkage" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints/gco:CharacterString = \"LicenseUrl:\"",
      "UseConstraints/LicenseText" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useConstraints/gmd:MD_RestrictionCode codeList \"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_RestrictionCode\" codeListValue \"otherRestrictions\" =  \"otherRestrictions\"
  /gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints/gco:CharacterString = \"LicenseText:\"",
      "AccessConstraints" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/",
      "AccessConstraints/Description" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation/gco:CharacterString (prefix: 'Restriction Comment:' )",
      "AccessConstraints/Value" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints/gco:CharacterString (prefix: 'Restriction Flag:' )",
      "ArchiveAndDistributionInformation/FileArchiveInformation" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceFormat/gmd:MD_Format [=>",
      "ArchiveAndDistributionInformation/FileArchiveInformation/Format" => "[=> /gmd:name/gco:CharacterString",
      "ArchiveAndDistributionInformation/FileArchiveInformation/FormatType" => "[=> /gmd:specification/gco:CharacterString = FormatType: <FormatType>",
      "ArchiveAndDistributionInformation/FileArchiveInformation/AverageFileSize" => "[=> /gmd:specification/gco:CharacterString = AverageFileSize: <AverageFileSize>",
      "ArchiveAndDistributionInformation/FileArchiveInformation/AverageFileSizeUnit" => "[=> /gmd:specification/gco:CharacterString = AverageFileSizeUnit: <AverageFileSizeUnit>",
      "ArchiveAndDistributionInformation/FileArchiveInformation/TotalCollectionFileSize" => "[=> /gmd:specification/gco:CharacterString = TotalCollectionFileSize: <TotalCollectionFileSize>",
      "ArchiveAndDistributionInformation/FileArchiveInformation/TotalCollectionFileSizeUnit" => "[=> /gmd:specification/gco:CharacterString = TotalCollectionFileSizeUnit: <TotalCollectionFileSizeUnit>",
      "ArchiveAndDistributionInformation/FileArchiveInformation/TotalCollectionFileSizeBeginDate" => "[=> /gmd:specification/gco:CharacterString =  TotalCollectionFileSizeBeginDate: <TotalCollectionFileSizeBeginDate>",
      "ArchiveAndDistributionInformation/FileArchiveInformation/Description" => "[=> /gmd:specification/gco:CharacterString =  Description: <Description>",
      "ArchiveAndDistributionInformation/FileDistributionInformation" => "/gmi:MI_Metadata/gmd:distributionInfo/gmd:MD_Distribution [=>",
      "ArchiveAndDistributionInformation/FileDistributionInformation/Format" => "[=> /gmd:distributionFormat xlink:href=\"FileDistributionInformation_<Block Number>\"/gmd:MD_Format/gmd:name/gco:CharacterString",
      "ArchiveAndDistributionInformation/FileDistributionInformation/FormatType" => "[=> /gmd:distributionFormat xlink:href=\"FileDistributionInformation_<Block Number>\"/gmd:MD_Format/gmd:specification/gmd:CharacterString = FormatType: <Native or Supported>",
      "ArchiveAndDistributionInformation/FileDistributionInformation/Media" => "[=> /gmd:transferOptions xlink:href=\"FileDistributionInformation_Media_<Block Number>\"gmd:MD_DigitalTransferOptions/gmd:offLine/gmd:MD_Medium/gmd:name/gmd:MD_MediumNameCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_MediumNameCode\" codeListValue=\"<value>\" = <value>",
      "ArchiveAndDistributionInformation/FileDistributionInformation/AverageFileSize" => "[=> /gmd:transferOptions xlink:href=\"FileDistributionInformation_AverageFileSize_<Block Number>\"/gmd:MD_DigitalTransferOptions/gmd:transferSize/gco:Real",
      "ArchiveAndDistributionInformation/FileDistributionInformation/AverageFileSizeUnit" => "[=> /gmd:transferOptions xlink:href=\"FileDistributionInformation_AverageFileSize_<Block Number>\"/gmd:MD_DigitalTransferOptions/gmd:unitsOfDistribution/gco:CharacterString",
      "ArchiveAndDistributionInformation/FileDistributionInformation/TotalCollectionFileSize" => "[=> /gmd:transferOptions xlink:href=\"FileDistributionInformation_TotalCollectionFileSize_<Block Number>\"/gmd:MD_DigitalTransferOptions/gmd:transferSize/gco:Real",
      "ArchiveAndDistributionInformation/FileDistributionInformation/TotalCollectionFileSizeUnit" => "[=> /gmd:transferOptions xlink:href=\"FileDistributionInformation_TotalCollectionFileSize_<Block Number>\"/gmd:MD_DigitalTransferOptions/gmd:unitsOfDistribution/gco:CharacterString",
      "ArchiveAndDistributionInformation/FileDistributionInformation/TotalCollectionFileSizeBeginDate" => "[=> /gmd:distributionFormat xlink:href=\"FileDistributionInformation_<Block Number>\"/gmd:MD_Format/gmd:specification/gmd:CharacterString = TotalCollectionFileSizeBeginDate: <Date use MMDDYYYYTHH:MM:SSZ format>",
      "ArchiveAndDistributionInformation/FileDistributionInformation/Description" => "[=> /gmd:distributor xlink:href=\"FileDistributionInformation_<Block Number>\"/gmd:MD_Distributor/gmd:distributionOrderProcess/gmd:MD_StandardOrderProcess/gmd:orderingInstructions/gmd:CharacterString",
      "ArchiveAndDistributionInformation/FileDistributionInformation/Fees" => "[=> /gmd:distributor xlink:href=\"FileDistributionInformation_<Block Number>\"/gmd:MD_Distributor/gmd:distributionOrderProcess/gmd:MD_StandardOrderProcess/gmd:fees/gmd:CharacterString",
      "MetadataAssociation/EntryId" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation
Metadata Associations:
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:associationType/gmd:DS_AssociationTypeCode  codeListValue=\"Science Associated\"
Parent Associations:
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:associationType/gmd:DS_AssociationTypeCode  codeListValue=\"largerWorkCitation\"",
      "PublicationReferences" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/",
      "PublicationReferences/Author" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:individualName or  gmd:/organisationName with
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role/CI_RoleCode=author",
      "PublicationReferences/Title" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:title",
      "PublicationReferences/Series" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:series/gmd:CI_Series/gmd:name",
      "PublicationReferences/Edition" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:edition",
      "PublicationReferences/ISBN" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:ISBN",
      "PublicationReferences/DOI" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/",
      "PublicationReferences/DOI/Authority" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:authority/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:organisationName or gmd:individualName",
      "PublicationReferences/DOI/DOI" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString
where
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:description/gco:CharacterString = DOI
and
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.doi",
      "PublicationReferences/OnlineResource" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:onlineResource/gmd:CI_OnlineResource",
      "PublicationReferences/OnlineResource/Linkage" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL",
      "PublicationReferences/OnlineResource/Protocol" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:onlineResource/gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString",
      "PublicationReferences/OnlineResource/ApplicationProfile" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:onlineResource/gmd:CI_OnlineResource/gmd:applicationProfile/gco:CharacterString",
      "PublicationReferences/OnlineResource/Name" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:onlineResource/gmd:CI_OnlineResource/gmd:name/gco:CharacterString",
      "PublicationReferences/OnlineResource/Description" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:onlineResource/gmd:CI_OnlineResource/gmd:description/gco:CharacterString=\"Description:\" and \"PublicationReference:\"",
      "PublicationReferences/OnlineResource/Function" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:onlineResource/gmd:CI_OnlineResource/gmd:function/gmd:CI_OnLineFunctionCode codeList=\"codeListLocation#CI_OnLineFunctionCode\" codeListValue=\"\" ",
      "ISOTopicCategories" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:topicCategory/gmd:MD_TopicCategoryCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_TopicCategoryCode\" codeListValue=\"{value}\">{value}",
      "ScienceKeywords" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/
write only:
If any keyword is missing and there exists a keyword later in the hierarchy (such as DetailedLocation), use NONE to fill in the values in between.
read only: don't use if a value = NONE.
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword",
      "ScienceKeywords/Category" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString  ( The first value - delimited by &gt; )
with
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gmd:type/MD_KeywordTypeCode[@codeListValue=\"theme\"]",
      "ScienceKeywords/Topic" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString  ( The second value - delimited by &gt; )
with
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gmd:type/MD_KeywordTypeCode[@codeListValue=\"theme\"]",
      "ScienceKeywords/Term" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString  ( The third value - delimited by &gt; )
with
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gmd:type/MD_KeywordTypeCode[@codeListValue=\"theme\"]",
      "ScienceKeywords/VariableLevel1" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString  ( The fourth value - delimited by &gt; )
with
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gmd:type/MD_KeywordTypeCode[@codeListValue=\"theme\"]",
      "ScienceKeywords/VariableLevel2" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString  ( The fifth value - delimited by &gt; )
with
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gmd:type/MD_KeywordTypeCode[@codeListValue=\"theme\"]",
      "ScienceKeywords/VariableLevel3" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString  ( The sixth value - delimited by &gt; )
with
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gmd:type/MD_KeywordTypeCode[@codeListValue=\"theme\"]",
      "ScienceKeywords/DetailedVariable" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString  ( The sixth value - delimited by &gt; )
with
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gmd:type/MD_KeywordTypeCode[@codeListValue=\"theme\"]",
      "AncillaryKeywords" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString",
      "AdditionalAttributes" => "/gmi:MI_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep/gmi:LE_ProcessStep/gmi:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute",
      "AdditionalAttributes/Name" => "/gmi:MI_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep/gmi:LE_ProcessStep/gmi:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:name/gco:CharacterString",
      "AdditionalAttributes/Type" => "/gmi:MI_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep/gmi:LE_ProcessStep/gmi:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:type/eos:EOS_AdditionalAttributeTypeCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/eosCodelists.xml#EOS_AdditionalAttributeTypeCode\" codeListValue=\"*type*\">*type*
  where *type* = processingInformation",
      "AdditionalAttributes/Identifier" => "/gmi:MI_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep/gmi:LE_ProcessStep/gmi:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString",
      "AdditionalAttributes/DataType" => "/gmi:MI_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep/gmi:LE_ProcessStep/gmi:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:dataType/eos:EOS_AdditionalAttributeDataTypeCode codeList=\"http://earthdata.nasa.gov/metadata/resources/Codelists.xml#EOS_AdditionalAttributeDataTypeCode\" codeListValue=\"*dataType*\">*dataType*</eos:EOS_AdditionalAttributeDataTypeCode>
  where *dataType* = STRING,FLOAT,INT, etc.",
      "AdditionalAttributes/Description" => "/gmi:MI_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep/gmi:LE_ProcessStep/gmi:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:description/gco:CharacterString",
      "AdditionalAttributes/MeasurementResolution" => "/gmi:MI_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep/gmi:LE_ProcessStep/gmi:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:measurementResolution/gco:CharacterString",
      "AdditionalAttributes/ParameterRangeBegin" => "/gmi:MI_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep/gmi:LE_ProcessStep/gmi:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:parameterRangeBegin/gco:CharacterString",
      "AdditionalAttributes/ParameterRangeEnd" => "/gmi:MI_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep/gmi:LE_ProcessStep/gmi:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:parameterRangeEnd/gco:CharacterString",
      "AdditionalAttributes/ParameterUnitsOfMeasure" => "/gmi:MI_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep/gmi:LE_ProcessStep/gmi:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:parameterUnitsOfMeasure/gco:CharacterString",
      "AdditionalAttributes/ParameterValueAccuracy" => "/gmi:MI_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep/gmi:LE_ProcessStep/gmi:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:parameterValueAccuracy/gco:CharacterString",
      "AdditionalAttributes/ValueAccuracyExplanation" => "/gmi:MI_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep/gmi:LE_ProcessStep/gmi:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:valueAccuracyExplanation/gco:CharacterString",
      "AdditionalAttributes/Value" => "/gmi:MI_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep/gmi:LE_ProcessStep/gmi:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:value/gco:CharacterString",
      "RelatedUrls" => "DistributionURL: GET DATA
/gmi:MI_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorTransferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine [=>
where the following doesn't equal or exist:
gmd:function/gmd:CI_OnLineFunctionCode codeList=\"http://www.ngdc.noaa.gov/metadata/published/xsd/schema/resources/Codelist/gmxCodelists.xml#CI_OnLineFunctionCode\" codeListValue=\"OPeNDAP\" and value = GET DATA : OPENDAP DATA (DODS)

  DistributionURL: GET SERVICE
  Read only: /gmi:MI_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorTransferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine
  where gmd:function/gmd:CI_OnLineFunctionCode codeList=\"http://www.ngdc.noaa.gov/metadata/published/xsd/schema/resources/Codelist/gmxCodelists.xml#CI_OnLineFunctionCode\" codeListValue=\"OPeNDAP\" and value = GET DATA : OPENDAP DATA (DODS)
  if above not preset look for:  write to:
      /gmi:MI_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorTransferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine
  where gmd:description/gco:CharacterString=\"URLContentType: DistributionURL\" and \"Type: GET SERVICE and Subtype: ...
and
/gmi:MI_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:serviceType/gco:LocalName=RelatedURL URLContentType: DistributionURL Type: GET SERVICE Subtype:...
with
<gmd:citation></gmd:citation>
<gmd:abstract></gmd:abstract>
<srv:couplingType><srv:SV_CouplingType codeList=\"\" codeListValue=\"\">tight

VisualizationURL:
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:graphicOverview [=>

DataCenterURL, DataContactURL: see
DataCenters/ContactPerson/ContactInformation/RelatedURLs
DataCenters/ContactGroup/ContactInformation/RelatedURLs
ContactPerson/ContactInformation/RelatedURLs
ContactGroup/ContactInformation/RelatedURLs
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/ [=>

CollectionURL, PublicationURL: /gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo [=>",
      "RelatedUrls/URL" => "DistributionURL: GET DATA and GET SERVICE:
[=>/gmd:CI_OnlineResource/gmd:linkage/gmd:URL
GET SERVICE:
/gmi:MI_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata/srv:connectPoint/gmd:CI_OnlineResource/gmd:linkage/gmd:URL

DataCenterURL, DataContactURL
[=>gmd:CI_ResponsibleParty/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL

CollectionURL, PublicationURL:
[=>/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL

VisualizationURL:  (Reading - look at first path first, if it doesn't exist then look at second path) (Writing - use first path only)
[=>/gmd:MD_BrowseGraphic/gmd:fileName/gmx:FileName src=  {also use source as element value} or
[=>/gmd:MD_BrowseGraphic/gmd:fileName/gco:CharacterString",
      "RelatedUrls/Description" => "DistributionURL: GET DATA and GET SERVICE
[=>/gmd:CI_OnlineResource/gmd:description/gco:CharacterString=\"Description:\"
GET SERVICE:
/gmi:MI_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata/srv:connectPoint/gmd:CI_OnlineResource/gmd:description/gco:CharacterString

DataCenterURL, DataContactURL
[=>gmd:CI_ResponsibleParty/gmd:onlineResource/gmd:CI_OnlineResource/gmd:description/gco:CharacterString=\"Description:\"

CollectionURL, PublicationURL:
[=>/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:onlineResource/gmd:CI_OnlineResource/gmd:description/gco:CharacterString
=\"Description:\"

VisualizationURL:
[=>/gmd:MD_BrowseGraphic/gmd:fileDescription/gco:CharacterString =\"Description:\"",
      "RelatedUrls/URLContentType" => "DistributionURL: GET DATA and GET SERVICE
[=>/gmd:CI_OnlineResource/gmd:description/gco:CharacterString=\"URLContentType:\"    reading: if not present put into DistributionURL
GET SERVICE
/gmi:MI_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:serviceType/gco:LocalName=RelatedURL URLContentType: DistributionURL Type: GET SERVICE Subtype:...

DataCenterURL, DataContactURL
[=>gmd:CI_ResponsibleParty/gmd:onlineResource/gmd:CI_OnlineResource/gmd:description/gco:CharacterString=\"URLContentType:\"  reading: if not present put into DataCenterURL or DataContactURL based on DataCenters or DataContacts

CollectionURL, PublicationURL:
[=>/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:onlineResource/gmd:CI_OnlineResource/gmd:description/gco:CharacterString=\"URLContentType:\"  reading: if not present and \"PublicationReference:\" not present then use PublicationURL. If \"PublicationReference:\" is present use UMM PublicationReference. - This change was also added to UMM PublicationReference.

VisualizationURL:
[=>/gmd:MD_BrowseGraphic/gmd:fileDescription/gco:CharacterString =\"URLContentType:\" reading: if not present put into VisualizationURL",
      "RelatedUrls/Type" => "DistributionURL: GET DATA and GET SERVICE
[=>/gmd:CI_OnlineResource/gmd:description/gco:CharacterString=\"Type:\"  reading: if not present and srv:SV_ServiceIdentification doesn't exist and the following doesn't exit:
where the following doesn't equal or exist:
gmd:function/gmd:CI_OnLineFunctionCode codeList=\"http://www.ngdc.noaa.gov/metadata/published/xsd/schema/resources/Codelist/gmxCodelists.xml#CI_OnLineFunctionCode\" codeListValue=\"OPeNDAP\" and value = GET DATA : OPENDAP DATA (DODS)
  use GET DATA if the above funtion element does exist or if srv:SV_ServiceIdentification exists use GET SERVICE
  GET SERVICE
  /gmi:MI_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:serviceType/gco:LocalName=RelatedURL URLContentType: DistributionURL Type: GET SERVICE Subtype:...

  DataCenterURL, DataContactURL
  [=>gmd:CI_ResponsibleParty/gmd:onlineResource/gmd:CI_OnlineResource/gmd:description/gco:CharacterString=\"Type:\"  reading: if not present use HOME PAGE

  CollectionURL, PublicationURL:
      [=>/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:onlineResource/gmd:CI_OnlineResource/gmd:description/gco:CharacterString
  =\"Type:\"
  CollectionURL - reading: if not present use PROJECT HOME PAGE
  PublicationURL - reading: if not present use VIEW RELATED INFORMATION

  VisualizationURL:
  [=>/gmd:MD_BrowseGraphic/gmd:fileDescription/gco:CharacterString =\"Type:\"     reading: if not present use GET RELATED VISUALIZATION",
      "RelatedUrls/Subtype" => "DistributionURL: GET DATA and GET SERVICE
[=>/gmd:CI_OnlineResource/gmd:description/gco:CharacterString=\"Subtype:\"  reading: if not present then Subtype isn't used.
GET SERVICE
/gmi:MI_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:serviceType/gco:LocalName=RelatedURL URLContentType: DistributionURL Type: GET SERVICE Subtype: {use list of valid values}

DataCenterURL, DataContactURL
[=>gmd:CI_ResponsibleParty/gmd:onlineResource/gmd:CI_OnlineResource/gmd:description/gco:CharacterString=\"Subtype:\"  reading: if not present then Subtype isn't used.

CollectionURL, PublicationURL:
[=>/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:onlineResource/gmd:CI_OnlineResource/gmd:description/gco:CharacterString
=\"Subtype:\"   reading: if not present then Subtype isn't used.

VisualizationURL:
[=>/gmd:MD_BrowseGraphic/gmd:fileDescription/gco:CharacterString =\"Subtype:\"     reading: if not present then Subtype isn't used.",
      "RelatedUrls/GetData/Format" => "/gmi:MI_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorFormat/gmd:MD_Format/gmd:name/gco:CharacterString = Format: <format>",
      "RelatedUrls/GetData/MimeType" => "/gmi:MI_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorFormat/gmd:MD_Format/gmd:name/gco:CharacterString = MimeType: <mime-type>",
      "RelatedUrls/GetData/Size" => "/gmi:MI_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorTransferOptions/gmd:MD_DigitalTransferOptions/gmd:transferSize",
      "RelatedUrls/GetData/Unit" => "/gmi:MI_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorTransferOptions/gmd:MD_DigitalTransferOptions/gmd:unitsOfDistribution/gco:CharacterString",
      "RelatedUrls/GetData/Fees" => "/gmi:MI_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributionOrderProcess/gmd:MD_StandardOrderProcess/gmd:fees",
      "RelatedUrls/GetData/Checksum" => "[=> /gmd:CI_OnlineResource/gmd:description/gco:CharacterString=\"Checksum:\"",
      "RelatedUrls/GetService/Format" => "/gmi:MI_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata/srv:operationDescription/gco:CharacterString=Format:",
      "RelatedUrls/GetService/MimeType" => "/gmi:MI_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata/srv:operationDescription/gco:CharacterString=Mimetype:",
      "RelatedUrls/GetService/Protocol" => "/gmi:MI_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata/srv:connectPoint/gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString",
      "RelatedUrls/GetService/FullName" => "/gmi:MI_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata/srv:operationName/gco:CharacterString",
      "RelatedUrls/GetService/DataID" => "/gmi:MI_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata/srv:operationDescription/gco:CharacterString=DataID:",
      "RelatedUrls/GetService/DataType" => "/gmi:MI_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata/srv:operationDescription/gco:CharacterString= DataType:",
      "RelatedUrls/GetService/URI" => "/gmi:MI_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata/srv:dependsOn/srv:SV_OperationMetadata/srv:connectPoint/gmd:CI_OnlineResource/gmd:linkage/gmd:URL",
      "TemporalExtents" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent",
      "TemporalExtents/PrecisionOfSeconds" => "/gmi:MI_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_AccuracyOfATimeMeasurement/gmd:measureIdentification/gmd:MD_Identifier/gmd:code/gco:CharacterString  PrecisionOfSeconds
and
/gmi:MI_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_AccuracyOfATimeMeasurement/gmd:result/gmd:DQ_QuantitativeResult/gmd:value/gco:Record xsi:type=\"gco:Real_PropertyType\"/gco:Real  - PrecisionOfSeconds Value",
      "TemporalExtents/EndsAtPresentFlag" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition indeterminatePosition=\"now\"",
      "TemporalExtents/RangeDateTimes/BeginningDateTime" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition",
      "TemporalExtents/RangeDateTimes/EndingDateTime" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition",
      "TemporalExtents/SingleDateTimes" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimeInstant/gml:timePosition",
      "TemporalKeywords" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString
with
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gmd:type/MD_KeywordTypeCode[@codeListValue=\"temporal\"]",
      "SpatialExtent" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent [=>
with gmd:EX_Extent attribute id=\"boundingExtent\"
Create a new gmd:extent - do not share with TilingInformationSystem",
      "SpatialExtent/SpatialCoverageType" => "[=>/gmd:description/gco:CharacterString  SpatialCoverageType=",
      "SpatialExtent/HorizontalSpatialDomain/ZoneIdentifier" => "[=>/gmd:geographicElement/gmd:EX_GeographicDescription id=\"ZoneIdentifier\"/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString
with
[=>/gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.zoneidentifier
and
[=>/gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:description/gco:CharacterString = ZoneIdentifier",
      "SpatialExtent/HorizontalSpatialDomain/Geometry/CoordinateSystem" => "[=>/gmd:description/gco:CharacterString  CoordinateSystem=",
      "SpatialExtent/HorizontalSpatialDomain/Geometry/Point" => "[=>/gmd:geographicElement/gmd:EX_BoundingPolygon/gmd:polygon/gml:Point/gml:pos srsName=\"http://www.opengis.net/def/crs/EPSG/4326\" srsDimension=\"2\">Latitude + \" \" + Longitude",
      "SpatialExtent/HorizontalSpatialDomain/Geometry/Point/Longitude" => "[=>/gmd:geographicElement/gmd:EX_BoundingPolygon/gmd:polygon/gml:Point/gml:pos srsName=\"http://www.opengis.net/def/crs/EPSG/4326\" srsDimension=\"2\">Latitude + \" \" + Longitude",
      "SpatialExtent/HorizontalSpatialDomain/Geometry/Point/Latitude" => "[=>/gmd:geographicElement/gmd:EX_BoundingPolygon/gmd:polygon/gml:Point/gml:pos srsName=\"http://www.opengis.net/def/crs/EPSG/4326\" srsDimension=\"2\">Latitude + \" \" + Longitude",
      "SpatialExtent/HorizontalSpatialDomain/Geometry/BoundingRectangles" => "[=>/gmd:geographicElement/gmd:EX_GeographicBoundingBox [==>",
      "SpatialExtent/HorizontalSpatialDomain/Geometry/BoundingRectangles/WestBoundingCoordinate" => "[==>/gmd:westBoundLongitude/gco:Decimal",
      "SpatialExtent/HorizontalSpatialDomain/Geometry/BoundingRectangles/NorthBoundingCoordinate" => "[==>/gmd:northBoundLongitude/gco:Decimal",
      "SpatialExtent/HorizontalSpatialDomain/Geometry/BoundingRectangles/EastBoundingCoordinate" => "[==>/gmd:eastBoundLongitude/gco:Decimal",
      "SpatialExtent/HorizontalSpatialDomain/Geometry/BoundingRectangles/SouthBoundingCoordinate" => "[==>/gmd:southBoundLongitude/gco:Decimal",
      "SpatialExtent/HorizontalSpatialDomain/Geometry/GPolygons" => "[=>/gmd:geographicElement/gmd:EX_BoundingPolygon/gmd:polygon/gml:Polygon srsName=\"http://www.opengis.net/def/crs/EPSG/9825\" [==>",
      "SpatialExtent/HorizontalSpatialDomain/Geometry/GPolygons/Boundary" => "[==>/gml:exterior/gml:LinearRing/gml:posList  {latitude first then longitude for every point - no commas just spaces. ex: -10 -10 -10 10 10 10 10 -10 -10 -10}",
      "SpatialExtent/HorizontalSpatialDomain/Geometry/GPolygons/Boundary/Points" => "[==>/gml:exterior/gml:LinearRing/gml:posList  {latitude first then longitude for every point - no commas just spaces. ex: -10 -10 -10 10 10 10 10 -10 -10 -10}",
      "SpatialExtent/HorizontalSpatialDomain/Geometry/GPolygons/Boundary/Points/Longitude" => "[==>/gml:exterior/gml:LinearRing/gml:posList  {latitude first then longitude for every point - no commas just spaces. ex: -10 -10 -10 10 10 10 10 -10 -10 -10}",
      "SpatialExtent/HorizontalSpatialDomain/Geometry/GPolygons/Boundary/Points/Latitude" => "[==>/gml:exterior/gml:LinearRing/gml:posList  {latitude first then longitude for every point - no commas just spaces. ex: -10 -10 -10 10 10 10 10 -10 -10 -10}",
      "SpatialExtent/HorizontalSpatialDomain/Geometry/GPolygons/ExclusiveZone/Boundaries" => "[==>/gml:interior/gml:LinearRing/gml:posList  {latitude first then longitude for every point - no commas just spaces. ex: -10 -10 -10 10 10 10 10 -10 -10 -10",
      "SpatialExtent/HorizontalSpatialDomain/Geometry/GPolygons/ExclusiveZone/Boundaries/Points" => "[==>/gml:interior/gml:LinearRing/gml:posList  {latitude first then longitude for every point - no commas just spaces. ex: -10 -10 -10 10 10 10 10 -10 -10 -10",
      "SpatialExtent/HorizontalSpatialDomain/Geometry/GPolygons/ExclusiveZone/Boundaries/Points/Longitude" => "[==>/gml:interior/gml:LinearRing/gml:posList  {latitude first then longitude for every point - no commas just spaces. ex: -10 -10 -10 10 10 10 10 -10 -10 -10",
      "SpatialExtent/HorizontalSpatialDomain/Geometry/GPolygons/ExclusiveZone/Boundaries/Points/Latitude" => "[==>/gml:interior/gml:LinearRing/gml:posList  {latitude first then longitude for every point - no commas just spaces. ex: -10 -10 -10 10 10 10 10 -10 -10 -10",
      "SpatialExtent/HorizontalSpatialDomain/Geometry/Lines" => "[=>/gmd:geographicElement/gmd:EX_BoundingPolygon/gmd:polygon/gml:LineString/gml:posList srsName=\"http://www.opengis.net/def/crs/EPSG/4326\" srsDimension=\"2\">lat-1 long-1 lat-2 long-2 etc.</gml:posList>",
      "SpatialExtent/HorizontalSpatialDomain/Geometry/Lines/Points" => "[=>/gmd:geographicElement/gmd:EX_BoundingPolygon/gmd:polygon/gml:LineString/gml:posList srsName=\"http://www.opengis.net/def/crs/EPSG/4326\" srsDimension=\"2\">lat-1 long-1 lat-2 long-2 etc.</gml:posList>",
      "SpatialExtent/HorizontalSpatialDomain/Geometry/Lines/Points/Longitude" => "[=>/gmd:geographicElement/gmd:EX_BoundingPolygon/gmd:polygon/gml:LineString/gml:posList srsName=\"http://www.opengis.net/def/crs/EPSG/4326\" srsDimension=\"2\">lat-1 long-1 lat-2 long-2 etc.</gml:posList>",
      "SpatialExtent/HorizontalSpatialDomain/Geometry/Lines/Points/Latitude" => "[=>/gmd:geographicElement/gmd:EX_BoundingPolygon/gmd:polygon/gml:LineString/gml:posList srsName=\"http://www.opengis.net/def/crs/EPSG/4326\" srsDimension=\"2\">lat-1 long-1 lat-2 long-2 etc.</gml:posList>",
      "SpatialExtent/HorizontalSpatialDomain/ResolutionAndCoordinateSystem/Description" => "[=> /gmd:geographicElement/gmd:EX_GeographicDescription id=\"horizontalresolutionandcoordinatesystem_description\"/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString = Description: description
with
[=>/gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.horizontalresolutionandcoordinatesystem_description
and
[=>/gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:description/gco:CharacterString = HorizontalResolutionAndCoordinateSystem_Description",
      "SpatialExtent/HorizontalSpatialDomain/ResolutionAndCoordinateSystem/GeodeticModel" => "[=> /gmd:geographicElement/gmd:EX_GeographicDescription id=\"horizontalresolutionandcoordinatesystem_geodeticmodel\"/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString = HorizontalDatumName: datum name Ellipsoidame: ellipsoid name SemiMajorAxis: number DenominatorOfFlatteningRatio: number
with
[=>/gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.horizontalresolutionandcoordinatesystem_geodeticmodel
and
[=>/gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:description/gco:CharacterString = HorizontalResolutionAndCoordinateSystem_GeodeticModel",
      "SpatialExtent/HorizontalSpatialDomain/ResolutionAndCoordinateSystem/GeodeticModel/HorizontalDatumName" => "[=> /gmd:geographicElement/gmd:EX_GeographicDescription id=\"horizontalresolutionandcoordinatesystem_geodeticmodel\"/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString = HorizontalDatumName: datum name Ellipsoidame: ellipsoid name SemiMajorAxis: number DenominatorOfFlatteningRatio: number
with
[=>/gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.horizontalresolutionandcoordinatesystem_geodeticmodel
and
[=>/gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:description/gco:CharacterString = HorizontalResolutionAndCoordinateSystem_GeodeticModel",
      "SpatialExtent/HorizontalSpatialDomain/ResolutionAndCoordinateSystem/GeodeticModel/EllipsoidName" => "[=> /gmd:geographicElement/gmd:EX_GeographicDescription id=\"horizontalresolutionandcoordinatesystem_geodeticmodel\"/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString = HorizontalDatumName: datum name Ellipsoidame: ellipsoid name SemiMajorAxis: number DenominatorOfFlatteningRatio: number
with
[=>/gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.horizontalresolutionandcoordinatesystem_geodeticmodel
and
[=>/gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:description/gco:CharacterString = HorizontalResolutionAndCoordinateSystem_GeodeticModel",
      "SpatialExtent/HorizontalSpatialDomain/ResolutionAndCoordinateSystem/GeodeticModel/SemiMajorAxis" => "[=> /gmd:geographicElement/gmd:EX_GeographicDescription id=\"horizontalresolutionandcoordinatesystem_geodeticmodel\"/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString = HorizontalDatumName: datum name Ellipsoidame: ellipsoid name SemiMajorAxis: number DenominatorOfFlatteningRatio: number
with
[=>/gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.horizontalresolutionandcoordinatesystem_geodeticmodel
and
[=>/gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:description/gco:CharacterString = HorizontalResolutionAndCoordinateSystem_GeodeticModel",
      "SpatialExtent/HorizontalSpatialDomain/ResolutionAndCoordinateSystem/GeodeticModel/DenominatorOfFlatteningRatio" => "[=> /gmd:geographicElement/gmd:EX_GeographicDescription id=\"horizontalresolutionandcoordinatesystem_geodeticmodel\"/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString = HorizontalDatumName: datum name Ellipsoidame: ellipsoid name SemiMajorAxis: number DenominatorOfFlatteningRatio: number
with
[=>/gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.horizontalresolutionandcoordinatesystem_geodeticmodel
and
[=>/gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:description/gco:CharacterString = HorizontalResolutionAndCoordinateSystem_GeodeticModel",
      # "SpatialExtent/HorizontalSpatialDomain/ResolutionAndCoordinateSystem/HorizontalDataResolution/GriddedResolutions/XDimension" => "",
      # "SpatialExtent/HorizontalSpatialDomain/ResolutionAndCoordinateSystem/HorizontalDataResolution/GriddedResolutions/YDimension" => "",
      # "SpatialExtent/HorizontalSpatialDomain/ResolutionAndCoordinateSystem/HorizontalDataResolution/GriddedResolutions/Unit" => "",
      # "SpatialExtent/HorizontalSpatialDomain/ResolutionAndCoordinateSystem/HorizontalDataResolution/NonGriddedResolutions/XDimension" => "",
      # "SpatialExtent/HorizontalSpatialDomain/ResolutionAndCoordinateSystem/HorizontalDataResolution/NonGriddedResolutions/YDimension" => "",
      # "SpatialExtent/HorizontalSpatialDomain/ResolutionAndCoordinateSystem/HorizontalDataResolution/NonGriddedResolutions/Unit" => "",
      # "SpatialExtent/HorizontalSpatialDomain/ResolutionAndCoordinateSystem/HorizontalDataResolution/NonGriddedResolutions/ViewingAngleType" => "",
      # "SpatialExtent/HorizontalSpatialDomain/ResolutionAndCoordinateSystem/HorizontalDataResolution/NonGriddedResolutions/ScanDirection" => "",
      # "SpatialExtent/HorizontalSpatialDomain/ResolutionAndCoordinateSystem/HorizontalDataResolution/GriddedRangeResolutions/MinimumXDimension" => "",
      # "SpatialExtent/HorizontalSpatialDomain/ResolutionAndCoordinateSystem/HorizontalDataResolution/GriddedRangeResolutions/MaximumXDimension" => "",
      # "SpatialExtent/HorizontalSpatialDomain/ResolutionAndCoordinateSystem/HorizontalDataResolution/GriddedRangeResolutions/MinimumYDimension" => "",
      # "SpatialExtent/HorizontalSpatialDomain/ResolutionAndCoordinateSystem/HorizontalDataResolution/GriddedRangeResolutions/MaximumYDimension" => "",
      "SpatialExtent/HorizontalSpatialDomain/ResolutionAndCoordinateSystem/LocalCoordinateSystem" => "[=> /gmd:geographicElement/gmd:EX_GeographicDescription id=\"horizontalresolutionandcoordinatesystem_localcoordinatesystem\"/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString = GeoReferenceInformation: value Description: value
with
[=>/gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.horizontalresolutionandcoordinatesystem_localcoordinatesystem
and
[=>/gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:description/gco:CharacterString = HorizontalResolutionAndCoordinateSystem_LocalCoordinateSystem",
      "SpatialExtent/HorizontalSpatialDomain/ResolutionAndCoordinateSystem/LocalCoordinateSystem/GeoReferenceInformation" => "[=> /gmd:geographicElement/gmd:EX_GeographicDescription id=\"horizontalresolutionandcoordinatesystem_localcoordinatesystem\"/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString = GeoReferenceInformation: value Description: value
with
[=>/gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.horizontalresolutionandcoordinatesystem_localcoordinatesystem
and
[=>/gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:description/gco:CharacterString = HorizontalResolutionAndCoordinateSystem_LocalCoordinateSystem",
      "SpatialExtent/HorizontalSpatialDomain/ResolutionAndCoordinateSystem/LocalCoordinateSystem/Description" => "[=> /gmd:geographicElement/gmd:EX_GeographicDescription id=\"horizontalresolutionandcoordinatesystem_localcoordinatesystem\"/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString = GeoReferenceInformation: value Description: value
with
[=>/gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.horizontalresolutionandcoordinatesystem_localcoordinatesystem
and
[=>/gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:description/gco:CharacterString = HorizontalResolutionAndCoordinateSystem_LocalCoordinateSystem",
      "SpatialExtent/VerticalSpatialDomains" => "[=>/gmd:geographicElement/gmd:EX_GeographicDescription id=\"VerticalSpatialDomainN\"/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString = Type: {Type} Value: {Value} Unit: {Unit}
with
[=>/gmd:geographicElement/gmd:EX_GeographicDescription id=\"VerticalSpatialDomainN\"/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.verticalspatialdomain
and
[=>/gmd:geographicElement/gmd:EX_GeographicDescription id=\"VerticalSpatialDomainN\" /gmd:geographicIdentifier/gmd:MD_Identifier/gmd:description/gco:CharacterString = VerticalSpatialDomain
Where VerticalSpatialDomainN = VerticalSpatialDomain0, VerticalSpatialDomain1, ... VerticalSpatailDomainN.",
      "SpatialExtent/VerticalSpatialDomains/Type" => "[=>/gmd:geographicElement/gmd:EX_GeographicDescription id=\"VerticalSpatialDomainN\"/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString = Type: {Type} Value: {Value} Unit: {Unit}
with
[=>/gmd:geographicElement/gmd:EX_GeographicDescription id=\"VerticalSpatialDomainN\"/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.verticalspatialdomain
and
[=>/gmd:geographicElement/gmd:EX_GeographicDescription id=\"VerticalSpatialDomainN\" /gmd:geographicIdentifier/gmd:MD_Identifier/gmd:description/gco:CharacterString = VerticalSpatialDomain
Where VerticalSpatialDomainN = VerticalSpatialDomain0, VerticalSpatialDomain1, ... VerticalSpatailDomainN.",
      "SpatialExtent/VerticalSpatialDomains/Value" => "[=>/gmd:geographicElement/gmd:EX_GeographicDescription id=\"VerticalSpatialDomainN\"/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString = Type: {Type} Value: {Value} Unit: {Unit}
with
[=>/gmd:geographicElement/gmd:EX_GeographicDescription id=\"VerticalSpatialDomainN\"/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.verticalspatialdomain
and
[=>/gmd:geographicElement/gmd:EX_GeographicDescription id=\"VerticalSpatialDomainN\" /gmd:geographicIdentifier/gmd:MD_Identifier/gmd:description/gco:CharacterString = VerticalSpatialDomain
Where VerticalSpatialDomainN = VerticalSpatialDomain0, VerticalSpatialDomain1, ... VerticalSpatailDomainN.",
      "SpatialExtent/OrbitParameters" => "[=>/gmd:geographicElement/gmd:EX_GeographicDescription id=\"OrbitParameters\"/gmd:geographicIdentifier/gmd:MD_Identifier[==>

[==>/gmd:description/gco:CharacterString = OrbitParameters
and
[==>/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.orbitparameters",
      "SpatialExtent/OrbitParameters/SwathWidth" => "[==>/gmd:code/gco:CharacterString = SwathWidth: {value}",
      "SpatialExtent/OrbitParameters/Period" => "[==>/gmd:code/gco:CharacterString = Period: {value}",
      "SpatialExtent/OrbitParameters/InclinationAngle" => "[==>/gmd:code/gco:CharacterString = InclinationAngle: {value}",
      "SpatialExtent/OrbitParameters/NumberOfOrbits" => "[==>/gmd:code/gco:CharacterString = NumberOfOrbits: {value}",
      "SpatialExtent/OrbitParameters/StartCircularLatitude" => "[==>/gmd:code/gco:CharacterString = StartCircularLatitude: {value}",
      "SpatialExtent/GranuleSpatialRepresentation" => "[=>/gmd:description/gco:CharacterString  SpatialGranuleSpatialRepresentation=

(CMR read only) If the above path does not exist then look here:
[=>/gmd:geographicElement/gmd:EX_GeographicDescription id=\"GranuleSpatialRepresentation\"/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString",
      "TilingIdentificationSystems" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent [=>
where attribute gmd:EX_Extent id=\"TilingIdentificationSystem\"
and
[=>/gmd:description/gco:CharacterString=\"Tiling Identification System\"
and
[=>/gmd:geographicElement/gmd:EX_GeographicDescription  [==>",
      "TilingIdentificationSystems/TilingIdentificationSystemName" => "[==>/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:description/gco:CharacterString",
      "TilingIdentificationSystems/Coordinate1" => "[==>/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code
with
[==>/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.tilingidentificationsystem",
      "TilingIdentificationSystems/Coordinate1/MinimumValue" => "[==>/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString= c1-min: <value>",
      "TilingIdentificationSystems/Coordinate1/MaximumValue" => "[=>/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString= c1-max: <value>",
      "TilingIdentificationSystems/Coordinate2" => "[==>/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code
with
[==>/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.tilingidentificationsystem",
      "TilingIdentificationSystems/Coordinate2/MinimumValue" => "[==>/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString= c2-min: <value>",
      "TilingIdentificationSystems/Coordinate2/MaximumValue" => "[==>/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString= c2-max: <value>",
      "SpatialInformation/SpatialCoverageType" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent id=\"boundingExtent\"/gmd:description/gco:CharacterString  SpatialInfoCoverageType=",
      "LocationKeywords" => "/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords [=>
write only:
If any keyword is missing and there exists a keyword later in the hierarchy (such as DetailedLocation), use NONE to fill in the values in between.
read only: don't use if a value = NONE.
[=>/gmd:keyword",
      "LocationKeywords/Category" => "[=>/gmd:keyword/gco:CharacterString  ( The first value - delimited by &gt; )
with
[=>/gmd:keyword/gmd:type/MD_KeywordTypeCode[@codeListValue=\"place\"]",
      "LocationKeywords/Type" => "[=>/gmd:keyword/gco:CharacterString  ( The second value - delimited by &gt; )
with
[=>/gmd:keyword/gmd:type/MD_KeywordTypeCode[@codeListValue=\"place\"]",
      "LocationKeywords/Subregion1" => "[=>/gmd:keyword/gco:CharacterString  ( The third value - delimited by &gt; )
with
[=>/gmd:keyword/gmd:type/MD_KeywordTypeCode[@codeListValue=\"place\"]",
      "LocationKeywords/Subregion2" => "[=>/gmd:keyword/gco:CharacterString  ( The fourth value - delimited by &gt; )
with
[=>/gmd:keyword/gmd:type/MD_KeywordTypeCode[@codeListValue=\"place\"]",
      "LocationKeywords/Subregion3" => "[=>/gmd:keyword/gco:CharacterString  ( The fifth value - delimited by &gt; )
with
[=>/gmd:keyword/gmd:type/MD_KeywordTypeCode[@codeListValue=\"place\"]",
      "LocationKeywords/DetailedLocation" => "[=>/gmd:keyword/gco:CharacterString  ( The sixth value - delimited by &gt; )
with
[=>/gmd:keyword/gmd:type/MD_KeywordTypeCode[@codeListValue=\"place\"]",
      "Platforms" => "/gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:platform/eos:EOS_Platform/[=>
with attribute on EOS_Platform id=\"da4ba326a-8251-40f5-825b-f50f1e6000e4\"  This id is unique only to a record and it matches the id of mountedOn xlink= in the instrument section.

(CMR read only - ISO Standard) If the xpath /gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:platform/eos:EOS_Platform/ doesn't exist look for /gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:platform/gmi:MI_Platform/",
      "Platforms/Type" => "[=>/gmd:description/gco:CharacterString",
      "Platforms/ShortName" => "[=>/gmi:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString
with
[=>/gmi:identifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.platformshortname
and  (write only)
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString
with
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gmd:type/MD_KeywordTypeCode[@codeListValue=\"platform\"]

(CMR read only - ISO Standard) If the xpath /gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:platform/eos:EOS_Platform/ doesn't exist look for /gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:platform/gmi:MI_Platform/gmi:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString  where Short Name needs to be parsed from Short Name &gt; Long Name",
      "Platforms/LongName" => "[=>/gmi:identifier/gmd:MD_Identifier/gmd:description/gco:CharacterString

(CMR read only - ISO Standard) If the xpath /gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:platform/eos:EOS_Platform/ doesn't exist look for /gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:platform/gmi:MI_Platform/gmi:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString  where Long Name needs to be parsed from Short Name &gt; Long Name",
      "Platforms/Characteristics" => "[=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:type/eos:EOS_AdditionalAttributeTypeCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/eosCodelists.xml#EOS_AdditionalAttributeTypeCode\" codeListValue=\"platformInformation\"=platformInformation",
      "Platforms/Characteristics/Name" => "[=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:name/gco:CharacterString",
      "Platforms/Characteristics/Description" => "[=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:description/gco:CharacterString",
      "Platforms/Characteristics/DataType" => "[=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:dataType/eos:EOS_AdditionalAttributeDataTypeCode
codeList=\"http://earthdata.nasa.gov/metadata/resources/Codelists.xml#EOS_AdditionalAttributeDataTypeCode\" codeListValue=<date type> value=<data type>",
      "Platforms/Characteristics/Unit" => "[=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:parameterUnitsOfMeasure/gco:CharacterString",
      "Platforms/Characteristics/Value" => "[=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:value/gco:CharacterString",
      "Platforms/Instruments" => "/gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:instrument/eos:EOS_Instrument [=>
with id=\"dc036b442-7d8d-45a4-9bbe-2954e8970b73\" - this id is generated just for a specific record that maps the platform with the instrument. You will notice that the ids are the same in the platform section for the xlink of instrument.

(CMR read only - ISO Standard) If the xpath /gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:instrument/eos:EOS_Instrument doesn't exist look for /gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:instrument/gmi:MI_Instrument/",
      "Platforms/Instruments/ShortName" => "[=>/gmi:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString
with
[=>/gmi:identifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.instrumentshortname
and (write only)
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString
with
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gmd:type/gmd:MD_KeywordTypeCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode\" codeListValue=\"instrument\"

  (CMR read only - ISO Standard) If the xpath /gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:instrument/eos:EOS_Instrument doesn't exist look for /gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:instrument/gmi:MI_Instrument/gmi:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString where Short Name needs to be parsed from Short Name &gt; Long Name",
      "Platforms/Instruments/LongName" => "[=>/gmi:identifier/gmd:MD_Identifier/gmd:description/gco:CharacterString

(CMR read only - ISO Standard) If the xpath /gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:instrument/eos:EOS_Instrument doesn't exist look for /gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:instrument/gmi:MI_Instrument/gmi:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString where Long Name needs to be parsed from Short Name &gt; Long Name",
      "Platforms/Instruments/Technique" => "[=>/gmi:type/gco:CharacterString",
      "Platforms/Instruments/NumberOfInstruments" => "when reading this will have to be counted.",
      "Platforms/Instruments/Characteristics" => "[=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:type/eos:EOS_AdditionalAttributeTypeCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/eosCodelists.xml#EOS_AdditionalAttributeTypeCode\" codeListValue=\"instrumentInformation\"=instrumentInformation",
      "Platforms/Instruments/Characteristics/Name" => "[=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:name/gco:CharacterString",
      "Platforms/Instruments/Characteristics/Description" => "[=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:description/gco:CharacterString",
      "Platforms/Instruments/Characteristics/DataType" => "[=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:dataType/eos:EOS_AdditionalAttributeDataTypeCode
codeList=\"http://earthdata.nasa.gov/metadata/resources/Codelists.xml#EOS_AdditionalAttributeDataTypeCode\" codeListValue=<date type> value=<data type>",
      "Platforms/Instruments/Characteristics/Unit" => "[=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:parameterUnitsOfMeasure/gco:CharacterString",
      "Platforms/Instruments/Characteristics/Value" => "[=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:value/gco:CharacterString",
      "Platforms/Instruments/OperationalModes" => "[=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:type/eos:EOS_AdditionalAttributeTypeCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/eosCodelists.xml#EOS_AdditionalAttributeTypeCode\" codeListValue=\"instrumentInformation\"=instrumentInformation
with
[=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:name/gco:CharacterString=\"OperationalMode\"
and
[=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:value/gco:CharacterString",
      "Platforms/Instruments/ComposedOf" => "/gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:instrument/eos:EOS_Instrument [=>
with id=\"dc036b442-7d8d-45a4-9bbe-2954e8970b74\" - this id is generated just for a specific record that maps the instrument with the parent instrument.
and read only:
/gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:instrument/eos:EOS_Instrument/eos:sensor/eos:EOS_Sensor [sensor=>
with id=\"sensor1\" - this id is generated just for a specific record that maps the sensor with the parent instrument.
(CMR read only - ISO Standard) If the xpath /gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:instrument/eos:EOS_Instrument doesn't exist look for /gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:instrument/gmi:MI_Instrument/",
      "Platforms/Instruments/ComposedOf/ShortName" => "[=>/gmi:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString
with
[=>/gmi:identifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.instrumentshortname
and (write only)
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString
with
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gmd:type/MD_KeywordTypeCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode\" codeListValue=\"instrument\"
  and (read only):
      [sensor=> /eos:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString
  with
  [=>/eos:identifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.sensorshortname
  (CMR read only - ISO Standard) If the xpath /gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:instrument/eos:EOS_Instrument doesn't exist look for /gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:instrument/gmi:MI_Instrument/gmi:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString where Short Name needs to be parsed from Short Name &gt; Long Name",
      "Platforms/Instruments/ComposedOf/LongName" => "[=>/gmi:identifier/gmd:MD_Identifier/gmd:description/gco:CharacterString
and (read only):
[sensor=>/eos:identifier/gmd:MD_Identifier/gmd:description/gco:CharacterString
(CMR read only - ISO Standard) If the xpath /gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:instrument/eos:EOS_Instrument doesn't exist look for /gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:instrument/gmi:MI_Instrument/gmi:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString where Long Name needs to be parsed from Short Name &gt; Long Name",
      "Platforms/Instruments/ComposedOf/Technique" => "[=>/gmi:type/gco:CharacterString
and (read only)
[sensor=>/eos:type/gco:CharacterString",
      "Platforms/Instruments/ComposedOf/Characteristics" => "[=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:type/eos:EOS_AdditionalAttributeTypeCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/eosCodelists.xml#EOS_AdditionalAttributeTypeCode\" codeListValue=\"instrumentInformation\"=instrumentInformation
  and (read only)
  [sensor=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:type/eos:EOS_AdditionalAttributeTypeCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/eosCodelists.xml#EOS_AdditionalAttributeTypeCode\" codeListValue=\"sensorInformation\"=sensorInformation",
      "Platforms/Instruments/ComposedOf/Characteristics/Name" => "[=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:name/gco:CharacterString
and (read only)
[sensor=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:name/gco:CharacterString",
      "Platforms/Instruments/ComposedOf/Characteristics/Description" => "[=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:description/gco:CharacterString
and (read only)
[sensor=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:description/gco:CharacterString",
      "Platforms/Instruments/ComposedOf/Characteristics/DataType" => "[=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:dataType/eos:EOS_AdditionalAttributeDataTypeCode
codeList=\"http://earthdata.nasa.gov/metadata/resources/Codelists.xml#EOS_AdditionalAttributeDataTypeCode\" codeListValue=<date type> value=<data type>
  and (read only)
  [sensor=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:dataType/eos:EOS_AdditionalAttributeDataTypeCode
  codeList=\"http://earthdata.nasa.gov/metadata/resources/Codelists.xml#EOS_AdditionalAttributeDataTypeCode\" codeListValue=<date type> value=<data type>",
      "Platforms/Instruments/ComposedOf/Characteristics/Unit" => "[=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:parameterUnitsOfMeasure/gco:CharacterString
and (read only)
[sensor=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:parameterUnitsOfMeasure/gco:CharacterString",
      "Platforms/Instruments/ComposedOf/Characteristics/Value" => "[=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:value/gco:CharacterString
and (read only)
[sensor=>/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:value/gco:CharacterString",
      "Projects" => "/gmi:MI_Metadata/gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:operation/gmi:MI_Operation/ [=>",
      "Projects/ShortName" => "[=>/gmi:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString
with
[=>/gmi:identifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.projectshortname
and (write only)
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString
with
/gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gmd:type/MD_KeywordTypeCode[@codeListValue=\"project\"]",
      "Projects/LongName" => "[=>/gmi:identifier/gmd:MD_Identifier/gmd:description/gco:CharacterString",
      "Projects/Campaigns" => "[=>/gmi:childOperation/gmi:MI_Operation/gmi:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString
with
[=>/gmi:childOperation/gmi:MI_Operation/gmi:identifier/gmd:MD_Identifier/gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.campaignshortname",
      "Projects/StartDate" => "[=>/gmi:description/gco:CharacterString StartDate:",
      "Projects/EndDate" => "[=>/gmi:description/gco:CharacterString EndDate:"
  }.freeze
end