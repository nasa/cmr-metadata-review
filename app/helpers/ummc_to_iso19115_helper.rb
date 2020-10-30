module UmmcToIso19115Helper
  def getFieldMapping(ummJsonField)
    FIELD_MAPPINGS[ummJsonField]
  end
  FIELD_MAPPINGS = {
    "MetadataLanguage": "/mdb:MD_Metadata/mdb:defaultLocale/lan:PT_Locale/lan:language/lan:LanguageCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#LanguageCode\"   codeListValue=
  with
  /mdb:MD_Metadata/mdb:defaultLocale/lan:PT_Locale/lan:characterEncoding/lan:MD_CharacterSetCode/ https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode\" codeListValue=\"utf8\"",
    "MetadataDate/Date": "/mdb:MD_Metadata/mdb:dateInfo/cit:CI_Date/cit:date/gco:DateTime
/mdb:MD_Metadata/mdb:dateInfo/cit:CI_Date/cit:dateType/cit:CI_DateTypeCode @codeList=\"codeListLocation#CI_DateTypeCode\" @codeListValue= creation, lastRevision, nextUpdated, expiry",
    "ShortName": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/[=>
[=> mcc:code/gco:CharacterString
[=> mcc:codeSpace/gco:CharacterString= gov.nasa.esdis.umm.shortname
[=> mcc:description/gco:CharacterString=Short Name",
    "Version": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:edition/gco:CharacterString",
    "VersionDescription": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:otherCitationDetails/gco:CharacterString",
    "EntryTitle": "/mdb:MD_Metadata/mdb:metadataIdentifier/mcc:MD_Identifier/mcc:code/gco:CharacterString
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:title/gco:CharacterString",
    "DOI": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/ [=>",
    "DOI/DOI": "[=> mcc:code/gco:CharacterString
and
[=> mcc:codeSpace = gov.nasa.esdis.umm.doi
and
[=> mcc:description/gco:CharacterString contains DOI
",
    "DOI/MissingReason": "[=> mcc:code nilReason=\"inapplicable\"
and
[=> mcc:codeSpace = gov.nasa.esdis.umm.doi
and
[=> mcc:description/gco:CharacterString contains DOI",
    "DOI/Authority": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/
cit:CI_Individual/cit:name or cit:CI_Organization/cit:name",
    "DOI/Explanation": "[=> mcc:description/gco:CharacterString contains Explanation:",
    "Abstract": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:abstract/gco:CharacterString",
    "Purpose": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:purpose/gco:CharacterString",
    "DataLanguage": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:defaultLocale/lan:PT_Locale/lan:language/lan:LanguageCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#LanguageCode\" codeListValue=
 with
 /mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:defaultLocale/lan:PT_Locale/lan:characterEncoding/lan:MD_CharacterSetCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode\"  codeListValue= ",
    "DataDate/Date": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:date/cit:CI_Date/cit:date/gco:DateTime
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:date/cit:CI_Date/cit:dateType/cit:CI_DateTypeCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode\"  codeListValue varies.",
    "DataCenters": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact/cit:CI_Responsibility
/mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/mrd:distributorContact/cit:CI_Responsibility
/mdb:MD_Metadata/db:resourceLineage/mrl:LI_Lineage/mrl:processStep/mil:LE_ProcessStep/mrl:processor/cit:CI_Responsibility",
    "DataCenters/Roles": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact/=>
/mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/=>
/mdb:MD_Metadata/db:resourceLineage/mrl:LI_Lineage/mrl:processStep/mil:LE_ProcessStep/mrl:processor/=>
=>cit:CI_Responsibility/cit:role/cit:CI_RoleCode codeList=\"codeListLocation#CI_RoleCode\" codeListValue=\"anyValidURI\"
 where the value = originator, custodian, processor, distributor",
    "DataCenters/ShortName": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact/=>
/mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/=>
/mdb:MD_Metadata/db:resourceLineage/mrl:LI_Lineage/mrl:processStep/mil:LE_ProcessStep/mrl:processor/=>
=>cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name/gco:CharacterString",
    "CollectionDataType": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/ [=>
[=> mcc:code/gco:CharacterString
and
[=>gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.collectiondatatype
and
[=> gmd:description/gco:CharacterString = Collection Data Type",
    "ProcessingLevel": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:processingLevel",
    "ProcessingLevel/Id": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:processingLevel/mcc:MD_Identifier/mcc:code/gco:CharacterString
and
/mdb:MD_Metadata/mdb:contentInfo/mdb:MD_ImageDescription/mdb:processingLevelCode/mcc:MD_Identifier/mcc:code/gco:CharacterString",
    "ProcessingLevel/Description": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:processingLevel/mcc:MD_Identifier/mcc:description/gco:CharacterString
and
/mdb:MD_Metadata/mdb:contentInfo/mdb:MD_ImageDescription/mdb:processingLevelCode/mcc:MD_Identifier/mcc:description/gco:CharacterString",
    "ResourceCitation": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation [=>",
    "CollectionCitation/Creators": "(READ from both individualName and organistionName and concatenate - WRITE to individual name only since we don't know how to parse the data.)
[=>/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/
cit:CI_Individual/cit:name/gco:CharacterString and/or [=>/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organization/cit:name/gco:CharacterString
with
[=>/cit:citedResponsibleParty/cit:CI_Responsibility/cit:role/cit:CI_RoleCode=author",
    "CollectionCitation/Editors": "(READ from both individualName and organistionName and concatenate - WRITE to individual name only since we don't know how to parse the data.
WRITE and READ - must have positionName and the value must be editor where the role is author)
[=>/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/
cit:CI_Individual/cit:name/gco:CharacterString and/or [=>/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organization/cit:name/gco:CharacterString
with
[=>/cit:citedResponsibleParty/cit:CI_Responsibility/cit:role/cit:CI_RoleCode=author",
    "CollectionCitation/Title": "[=>/cit:title/gco:CharacterString",
    "CollectionCitation/SeriesName": "[=>/cit:series/cit:CI_Series/cit:name/gco:CharacterString",
    "CollectionCitation/ReleaseDate": "[=>/cit:editionDate/gco:DateTime",
    "CollectionCitation/ReleasePlace": "(READ - concatenate all elements
WRITE - if parsable parse into individual components if not then put all into deliveryPoint)
[=>/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address [==>
[==>/cit:deliveryPoint
[==>/cit:city/gco:CharacterString (0..1)
[==>/cit:administrativeArea/gco:CharacterString (0..1)
[==>./cit:postalCode/gco:CharacterString (0..1)
[==>/cit:country/gco:CharacterString (0..1)
[==>/cit:electronicMailAddress/gco:CharacterString (0..*)",
    "CollectionCitation/Publisher": "(READ from both individualName and organistionName and concatenate - WRITE to individual name only since we don't know how to parse the data.)
[=>/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/
cit:CI_Individual/cit:name/gco:CharacterString and/or [=>/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organization/cit:name/gco:CharacterString
with
[=>/cit:citedResponsibleParty/cit:CI_Responsibility/cit:role/cit:CI_RoleCode=publisher",
    "CollectionCitation/Version": "[=>/cit:edition/gco:CharacterString",
    "CollectionCitation/IssueIdentification": "[=>/cit:series/cit:CI_Series/cit:issueIdentification/gco:CharacterString",
    "CollectionCitation/DataPresentationForm": "[=>/cit:presentationForm/cit:CI_PresentationFormCode codeList="" codeListValue="" =",
    "CollectionCitation/OtherCitationDetails": "[=>/cit:otherCitationDetails/gco:CharacterString",
    "CollectionCitation/OnlineResource": "[=>/cit:onlineResource/cit:CI_OnlineResource [===>",
    "CollectionCitation/OnlineResource/Linkage": "[===>/cit:linkage/gco:CharacterString",
    "CollectionCitation/OnlineResource/Protocol": "[===>/cit:protocol/gco:CharacterString",
    "CollectionCitation/OnlineResource/ApplicationProfile": "[===>/cit:applicationProfile/gco:CharacterString",
    "CollectionCitation/OnlineResource/Name": "[===>/cit:name/gco:CharacterString",
    "CollectionCitation/OnlineResource/Description": "[===>/cit:description/gco:CharacterString",
    "CollectionCitation/OnlineResource/Function": "[===>/cit:function/cit:CI_OnLineFunctionCode codeList=\"codeListLocation#CI_OnLineFunctionCode\" codeListValue=\"information\" =information",
    "CollectionProgress": "/mdb:MI_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:status/mri:MD_ProgressCode",
    "Quality": "/mdb:MD_Metadata/mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_DomainConsistency/mdq:result/mdq:DQ_DescriptiveResult/mdq:statement/gco:CharacterString",
    "UseConstraints": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints/mco:MD_LegalConstraints/mco:useLimitation/gco:CharacterString",
    "UseConstraints/Description": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints/mco:MD_LegalConstraints/mco:useLimitation/gco:CharacterString",
    "UseConstraints/LicenseUrl": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints/mco:MD_LegalConstraints/mco:useConstraints/mco:MD_RestrictionCode codeList \"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_RestrictionCode\" codeListValue \"otherRestrictions\" =  \"otherRestrictions\"",
    "UseConstraints/LicenseUrl/Linkage": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints/mco:MD_LegalConstraints/mco:otherConstraints/gco:mcoCharacterString = \"LicenseUrl:\"",
    "UseConstraints/LicenseText": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints/mco:MD_LegalConstraints/mco:useConstraints/mco:MD_RestrictionCode codeList \"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_RestrictionCode\" codeListValue \"otherRestrictions\" =  \"otherRestrictions\"
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints/mco:MD_LegalConstraints/mco:otherConstraints/gco:mcoCharacterString = \"LicenseText:\"",
    "AccessConstraints": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints/mco:MD_LegalConstraints/ [=>",
    "AccessConstraints/Description": "[=> mco:accessConstriants/mco:MD_RestrictionCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_RestrictionCode\" codeListValue=\"otherRestrictions\"=otherRestrictions
[=> mco:otherConstraints/gco:CharacterString (prefix:'Access Constraints Description:')",
    "AccessConstraints/Value": "[=> mco:accessConstriants/mco:MD_RestrictionCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_RestrictionCode\" codeListValue=\"otherRestrictions\"=otherRestrictions
[=> mco:otherConstraints/gco:CharacterString (prefix:'Access Constraints Value:')",
    "MetadataAssociation/EntryId": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:associatedResource/mri:MD_AssociatedResource/mri:name
Metadata Associations:
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:associatedResource/mri:MD_AssociatedResource/mri:associationType/mri:DS_AssociationTypeCode codeList=\"codeListLocation#DS_AssociationTypeCode\"codeListValue=\"Science Associated\"
Parent Associations:
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:associatedResource/mri:MD_AssociatedResource/mri:associationType/mri:DS_AssociationTypeCode codeList=\"codeListLocation#DS_AssociationTypeCode\"codeListValue=\"largerWorkCitation\"",
    "PublicationReference": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:additionalDocumentation/",
    "PublicationReference/Authors": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/
cit:CI_Individual/cit:name or cit:CI_Organization/cit:name
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:role/cit:CI_RoleCode=author",
    "PublicationReference/Title": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:title",
    "PublicationReference/Series": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:series/cit:CI_Series/cit:name",
    "PublicationReference/Edition": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:edition",
    "PublicationReference/ISBN": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:ISBN",
    "PublicationReference/DOI": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/",
    "DOI only": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:description/gco:CharacterString = DOI
and
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:codeSpace = gov.nasa.esdis.umm.doi",
    "PublicationReference/DOI/Authority": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/
cit:CI_Individual/cit:name or cit:CI_Organization/cit:name",
    "PublicationReference/DOI/DOI": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString
where
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:description/gco:CharacterString = DOI
and
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:codeSpace = gov.nasa.esdis.umm.doi",
    "ISOTopicCategory": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:topicCategory/mri:MD_TopicCategoryCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_TopicCategoryCode\" codeListValue=\"{value}\">{value}",
    "ScienceKeywords": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords
write only:
If any keyword is missing and there exists a keyword later in the hierarchy (such as DetailedLocation), use NONE to fill in the values in between.
read only: don't use if a value = NONE.
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword",
    "ScienceKeywords/Category": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString  ( The first value - delimited by &gt; )
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"theme\"",
    "ScienceKeywords/Topic": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString  ( The second value - delimited by &gt; )
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"theme\"",
    "ScienceKeywords/Term": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString  ( The third value - delimited by &gt; )
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"theme\"",
    "ScienceKeywords/VariableLevel1": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString  ( The fourth value - delimited by &gt; )
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"theme\"",
    "ScienceKeywords/VariableLevel2": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString  ( The fifth value - delimited by &gt; )
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"theme\"",
    "ScienceKeywords/VariableLevel3": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString  ( The sixth value - delimited by &gt; )
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"theme\"",
    "ScienceKeywords/DetailedVariable": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString  ( The sixth value - delimited by &gt; )
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"theme\"",
    "AncillaryKeywords": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString",
    "AdditionalAttributes": "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute",
    "AdditionalAttribute/Name": "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:name/gco:CharacterString",
    "AdditionalAttribute/Type": "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:type/eos:EOS_AdditionalAttributeTypeCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/eosCodelists.xml#EOS_AdditionalAttributeTypeCode\" codeListValue=\"*type*\">*type*
  where *type* = processingInformation",
    "AdditionalAttribute/Identifier": "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString",
    "AdditionalAttribute/DataType": "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:dataType/eos:EOS_AdditionalAttributeDataTypeCode codeList=\"http://earthdata.nasa.gov/metadata/resources/Codelists.xml#EOS_AdditionalAttributeDataTypeCode\" codeListValue=\"*dataType*\">*dataType*</eos:EOS_AdditionalAttributeDataTypeCode>
  where *dataType* = STRING,FLOAT,INT, etc.",
    "AdditionalAttribute/Description": "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:description/gco:CharacterString",
    "AdditionalAttribute/MeasurementResolution": "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:measurementResolution/gco:CharacterString",
    "AdditionalAttribute/ParameterRangeBegin": "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:parameterRangeBegin/gco:CharacterString",
    "AdditionalAttribute/ParameterRangeEnd": "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:parameterRangeEnd/gco:CharacterString",
    "AdditionalAttribute/ParameterUnitsOfMeasure": "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:parameterUnitsOfMeasure/gco:CharacterString",
    "AdditionalAttribute/ParameterValueAccuracy": "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:parameterValueAccuracy/gco:CharacterString",
    "AdditionalAttribute/ValueAccuracyExplanation": "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:valueAccuracyExplanation/gco:CharacterString",
    "AdditionalAttribute/Value": "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:value/gco:CharacterString",
    "TemporalExtent": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent",
    "TemporalExtent/TemporalRangeType": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:description/gco:CharacterString DateType=",
    "TemporalExtent/PrecisionOfSeconds": "/mdb:MD_Metadata/mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_AccuracyOfATimeMeasurement/mdq:measure/mdq:DQ_MeasureReference/mdq:measureIdentification/mcc:MD_Identifier/mcc:code/gco:CharacterString =  PrecisionOfSeconds
and
/mdb:MD_Metadata/mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_AccuracyOfATimeMeasurement/mdq:result/mdq:DQ_QuantitativeResult/mdq:value/gco:Record xsi:type=\"gco:Real_PropertyType\"/gco:Real   PrecisionOfSeconds Value",
    "TemporalExtent/EndsAtPresentFlag": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:endPosition indeterminatePosition=\"now\"",
    "TemporalExtent/RangeDateTime/BeginningDateTime": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:beginPosition",
    "TemporalExtent/RangeDateTime/EndingDateTime": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:endPosition",
    "TemporalExtent/SingleDateTime": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/ gml:TimeInstant/gml:timePosition",
    "TemporalKeywords": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:type/mri:MD_KeywordTypeCode[@codeListValue=\"temporal\"]",
    "SpatialExtent": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent[@id='boundingExtent'] [=>
Create a new gmd:extent - do not share with TilingInformationSystem",
    "SpatialExtent/SpatialCoverageType": "[=>/gex:description/gco:CharacterString SpatialCoverageType=",
    "SpatialExtent/HorizontaSpatialDomain/ZoneIdentifier": "[=>/gex:geographicElement/gex:EX_GeographicDescription/gex:geographicIdentifier/mcc:MD_Identifier/mcc:code/gco:CharacterString
with
[=>/gex:geographicElement/gex:EX_GeographicDescription/gex:geographicIdentifier/mcc:MD_Identifier/mcc:description/gco:CharacterString = ZoneIdentifier",
    "SpatialExtent/HorizontaSpatialDomain/Geometry/BoundingRectangles/WestBoundingCoordinate": "[=>/gex:geographicElement/gex:EX_GeographicBoundingBox/gex:westBoundLongitude/gco:Decimal",
    "SpatialExtent/HorizontaSpatialDomain/Geometry/BoundingRectangles/NorthBoundingCoordinate": "[=>/gex:geographicElement/gex:EX_GeographicBoundingBox/gex:northBoundLongitude/gco:Decimal",
    "SpatialExtent/HorizontaSpatialDomain/Geometry/BoundingRectangles/EastBoundingCoordinate": "[=>/gex:geographicElement/gex:EX_GeographicBoundingBox/gex:eastBoundLongitude/gco:Decimal",
    "SpatialExtent/HorizontaSpatialDomain/Geometry/BoundingRectangles/SouthBoundingCoordinate": "[=>/gex:geographicElement/gex:EX_GeographicBoundingBox/gex:southBoundLongitude/gco:Decimal",
    "SpatialExtent/VerticalSpatialDomain": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent[@id='boundingExtent']/gex:description/gco:CharacterString
with format:
VerticalSpatialDomainType= {type}, VerticalSpatialDomainValue= {value}",
    "SpatialExtent/VerticalSpatialDomain/Type": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent[@id='boundingExtent']/gex:description/gco:CharacterString
with format:
VerticalSpatialDomainType= {type}, VerticalSpatialDomainValue= {value}",
    "SpatialExtent/VerticalSpatialDomain/Value": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent[@id='boundingExtent']/gex:description/gco:CharacterString
with format:
VerticalSpatialDomainType= {type}, VerticalSpatialDomainValue= {value}",
    "SpatialExtent/VerticalSpatialDomain/Unit": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent[@id='boundingExtent']/gex:description/gco:CharacterString
with format:
VerticalSpatialDomainType= {type}, VerticalSpatialDomainValue= {value}",
    "SpatialExtent/GranuleSpatialRepresentation": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent[@id='boundingExtent']/gex:description/gco:CharacterString SpatialGranuleSpatialRepresentation=",
    "LocationKeywords": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords [=>
write only:
If any keyword is missing and there exists a keyword later in the hierarchy (such as DetailedLocation), use NONE to fill in the values in between.
read only: don't use if a value = NONE.
[=>/mri:keyword",
    "LocationKeywords/Category": "[=>/mri:keyword/gco:CharacterString  ( The first value - delimited by &gt; )
with
[=>/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"place\"",
    "LocationKeywords/Type": "[=>/mri:keyword/gco:CharacterString  ( The second value - delimited by &gt; )
with
[=>/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"place\"",
    "LocationKeywords/Subregion1": "[=>/mri:keyword/gco:CharacterString  ( The third value - delimited by &gt; )
with
[=>/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"place\"",
    "LocationKeywords/Subregion2": "[=>/mri:keyword/gco:CharacterString  ( The fourth value - delimited by &gt; )
with
[=>/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"place\"",
    "LocationKeywords/Subregion3": "[=>/mri:keyword/gco:CharacterString  ( The fifth value - delimited by &gt; )
with
[=>/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"place\"",
    "LocationKeywords/DetailedLocation": "[=>/mri:keyword/gco:CharacterString  ( The sixth value - delimited by &gt; )
with
[=>/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"place\"",
    "Platform": "/mdb:MD_Metadata/mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:platform/mac:MI_Platform id=",
    "Platform/ShortName": "/mdb:MD_Metadata/mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:platform/mac:MI_Platform id="..."/mac:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString
and
(CMR write only)
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode\" ListValue=\"platform\"",
    "Platform/Instrument": "/mdb:MD_Metadata/mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:instrument/mac:MI_Instrument id=",
    "Platform/Instrument/ShortName": "/mdb:MD_Metadata/mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:instrument/mac:MI_Instrument id="..."/mac:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString
and
(CMR write only)
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode\" codeListValue=\"instrument\"",
    "Platform/Instrument/ComposedOf/ShortName": "/mdb:MD_Metadata/mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:instrument/mac:MI_Instrument id="..."/mac:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString
and
(CMR write only)
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode\" codeListValue=\"instrument\"",
    "Project": "/mdb:MD_Metadata/mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:operation/mac:MI_Operation/ [=>",
    "Project/ShortName": "[=>mac:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString
[=>mac:identifier/mcc:MD_Identifier/mcc:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.projectshortname
and (CMR write only)
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=\"http://www.ngdc.noaa.gov/metadata/published/xsd/schema/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode\" codeListValue=\"project\"",
    "Project/LongName": "[=> mac:identifier/mcc:MD_Identifier/mcc:description/gco:CharacterString",
    "Project/Campaign": "[=> mac:childOperation/mac:MI_Operation/mac:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString
with
[=> mac:childOperation/mac:MI_Operation/mac:identifier/mcc:MD_Identifier/mcc:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.campaignshortname",
    "Project/StartDate": "[=>/mac:description/gco:CharacterString StartDate:",
    "Project/EndDate": "[=>/mac:description/gco:CharacterString EndDate:",
    "Maturity": "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/ [=>
[=> mcc:code/gco:CharacterString
and
[=>gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.maturity
and
[=> gmd:description/gco:CharacterString = Maturity"
  }
end