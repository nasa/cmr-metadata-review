module UmmcToIso19115Helper
  def getISOFieldMapping(ummJsonField)
    value = FIELD_MAPPINGS[ummJsonField]
    if value.blank?
      value = "No ISO mapping available"
    end
    value
  end
  FIELD_MAPPINGS = {
    "MetadataLanguage" => "/mdb:MD_Metadata/mdb:defaultLocale/lan:PT_Locale/lan:language/lan:LanguageCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#LanguageCode\"   codeListValue=
  with
/mdb:MD_Metadata/mdb:defaultLocale/lan:PT_Locale/lan:characterEncoding/lan:MD_CharacterSetCode/ https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode\" codeListValue=\"utf8\"",
    "MetadataDates/Date" => "/mdb:MD_Metadata/mdb:dateInfo/cit:CI_Date/cit:date/gco:DateTime
/mdb:MD_Metadata/mdb:dateInfo/cit:CI_Date/cit:dateType/cit:CI_DateTypeCode @codeList=\"codeListLocation#CI_DateTypeCode\" @codeListValue= creation, lastRevision, nextUpdated, expiry",
    "ShortName" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/[=>
[=> mcc:code/gco:CharacterString
[=> mcc:codeSpace/gco:CharacterString= gov.nasa.esdis.umm.shortname
[=> mcc:description/gco:CharacterString=Short Name",
    "Version" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:edition/gco:CharacterString",
    "VersionDescription" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:otherCitationDetails/gco:CharacterString",
    "EntryTitle" => "/mdb:MD_Metadata/mdb:metadataIdentifier/mcc:MD_Identifier/mcc:code/gco:CharacterString
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:title/gco:CharacterString",
    "DOI" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/ [=>",
    "DOI/DOI" => "[=> mcc:code/gco:CharacterString
and
[=> mcc:codeSpace = gov.nasa.esdis.umm.doi
and
[=> mcc:description/gco:CharacterString contains DOI
",
    "DOI/MissingReason" => "[=> mcc:code nilReason=\"inapplicable\"
and
[=> mcc:codeSpace = gov.nasa.esdis.umm.doi
and
[=> mcc:description/gco:CharacterString contains DOI",
    "DOI/Authority" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/
cit:CI_Individual/cit:name or cit:CI_Organization/cit:name",
    "DOI/Explanation" => "[=> mcc:description/gco:CharacterString contains Explanation:",
    "Abstract" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:abstract/gco:CharacterString",
    "Purpose" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:purpose/gco:CharacterString",
    "DataLanguage" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:defaultLocale/lan:PT_Locale/lan:language/lan:LanguageCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#LanguageCode\" codeListValue=

with

 /mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:defaultLocale/lan:PT_Locale/lan:characterEncoding/lan:MD_CharacterSetCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode\"  codeListValue= ",
    "DataDates/Date" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:date/cit:CI_Date/cit:date/gco:DateTime
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:date/cit:CI_Date/cit:dateType/cit:CI_DateTypeCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode\"  codeListValue varies.",
    "DataCenters" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact/cit:CI_Responsibility
/mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/mrd:distributorContact/cit:CI_Responsibility
/mdb:MD_Metadata/db:resourceLineage/mrl:LI_Lineage/mrl:processStep/mil:LE_ProcessStep/mrl:processor/cit:CI_Responsibility",
    "DataCenters/Roles" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact/=>
/mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/=>
/mdb:MD_Metadata/db:resourceLineage/mrl:LI_Lineage/mrl:processStep/mil:LE_ProcessStep/mrl:processor/=>
=>cit:CI_Responsibility/cit:role/cit:CI_RoleCode codeList=\"codeListLocation#CI_RoleCode\" codeListValue=\"anyValidURI\"
 where the value = originator, custodian, processor, distributor",
    "DataCenters/ShortName" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact/=>
/mdb:MD_Metadata/mdb:distributionInfo/mrd:MD_Distribution/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/=>
/mdb:MD_Metadata/db:resourceLineage/mrl:LI_Lineage/mrl:processStep/mil:LE_ProcessStep/mrl:processor/=>
=>cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name/gco:CharacterString",
    "CollectionDataType" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/ [=>
[=> mcc:code/gco:CharacterString
and
[=>gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.collectiondatatype
and
[=> gmd:description/gco:CharacterString = Collection Data Type",
    "ProcessingLevel" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:processingLevel",
    "ProcessingLevel/Id" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:processingLevel/mcc:MD_Identifier/mcc:code/gco:CharacterString
and
/mdb:MD_Metadata/mdb:contentInfo/mdb:MD_ImageDescription/mdb:processingLevelCode/mcc:MD_Identifier/mcc:code/gco:CharacterString",
    "ProcessingLevel/ProcessingLevelDescription" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:processingLevel/mcc:MD_Identifier/mcc:description/gco:CharacterString
and
/mdb:MD_Metadata/mdb:contentInfo/mdb:MD_ImageDescription/mdb:processingLevelCode/mcc:MD_Identifier/mcc:description/gco:CharacterString",
    "CollectionCitations" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation [=>",
    "CollectionCitations/Creator" => "(READ from both individualName and organistionName and concatenate - WRITE to individual name only since we don't know how to parse the data.)
[=>/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/
cit:CI_Individual/cit:name/gco:CharacterString and/or [=>/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organization/cit:name/gco:CharacterString
with
[=>/cit:citedResponsibleParty/cit:CI_Responsibility/cit:role/cit:CI_RoleCode=author",
    "CollectionCitations/Editor" => "(READ from both individualName and organistionName and concatenate - WRITE to individual name only since we don't know how to parse the data.
WRITE and READ - must have positionName and the value must be editor where the role is author)
[=>/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/
cit:CI_Individual/cit:name/gco:CharacterString and/or [=>/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organization/cit:name/gco:CharacterString
with
[=>/cit:citedResponsibleParty/cit:CI_Responsibility/cit:role/cit:CI_RoleCode=author",
    "CollectionCitations/Title" => "[=>/cit:title/gco:CharacterString",
    "CollectionCitations/SeriesName" => "[=>/cit:series/cit:CI_Series/cit:name/gco:CharacterString",
    "CollectionCitations/ReleaseDate" => "[=>/cit:editionDate/gco:DateTime",
    "CollectionCitations/ReleasePlace" => "(READ - concatenate all elements
WRITE - if parsable parse into individual components if not then put all into deliveryPoint)
[=>/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address [==>
[==>/cit:deliveryPoint
[==>/cit:city/gco:CharacterString (0..1)
[==>/cit:administrativeArea/gco:CharacterString (0..1)
[==>./cit:postalCode/gco:CharacterString (0..1)
[==>/cit:country/gco:CharacterString (0..1)
[==>/cit:electronicMailAddress/gco:CharacterString (0..*)",
    "CollectionCitations/Publisher" => "(READ from both individualName and organistionName and concatenate - WRITE to individual name only since we don't know how to parse the data.)
[=>/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/
cit:CI_Individual/cit:name/gco:CharacterString and/or [=>/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organization/cit:name/gco:CharacterString
with
[=>/cit:citedResponsibleParty/cit:CI_Responsibility/cit:role/cit:CI_RoleCode=publisher",
    "CollectionCitations/Version" => "[=>/cit:edition/gco:CharacterString",
    "CollectionCitations/IssueIdentification" => "[=>/cit:series/cit:CI_Series/cit:issueIdentification/gco:CharacterString",
    "CollectionCitations/DataPresentationForm" => "[=>/cit:presentationForm/cit:CI_PresentationFormCode codeList="" codeListValue="" =",
    "CollectionCitations/OtherCitationDetails" => "[=>/cit:otherCitationDetails/gco:CharacterString",
    "CollectionCitations/OnlineResource" => "[=>/cit:onlineResource/cit:CI_OnlineResource [===>",
    "CollectionCitations/OnlineResource/Linkage" => "[===>/cit:linkage/gco:CharacterString",
    "CollectionCitations/OnlineResource/Protocol" => "[===>/cit:protocol/gco:CharacterString",
    "CollectionCitations/OnlineResource/ApplicationProfile" => "[===>/cit:applicationProfile/gco:CharacterString",
    "CollectionCitations/OnlineResource/Name" => "[===>/cit:name/gco:CharacterString",
    "CollectionCitations/OnlineResource/Description" => "[===>/cit:description/gco:CharacterString",
    "CollectionCitations/OnlineResource/Function" => "[===>/cit:function/cit:CI_OnLineFunctionCode codeList=\"codeListLocation#CI_OnLineFunctionCode\" codeListValue=\"information\" =information",
    "CollectionProgress" => "/mdb:MI_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:status/mri:MD_ProgressCode",
    "Quality" => "/mdb:MD_Metadata/mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_DomainConsistency/mdq:result/mdq:DQ_DescriptiveResult/mdq:statement/gco:CharacterString",
    "UseConstraints" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints/mco:MD_LegalConstraints/mco:useLimitation/gco:CharacterString",
    "UseConstraints/Description" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints/mco:MD_LegalConstraints/mco:useLimitation/gco:CharacterString",
    "UseConstraints/LicenseUrl" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints/mco:MD_LegalConstraints/mco:useConstraints/mco:MD_RestrictionCode codeList \"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_RestrictionCode\" codeListValue \"otherRestrictions\" =  \"otherRestrictions\"",
    "UseConstraints/LicenseUrl/Linkage" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints/mco:MD_LegalConstraints/mco:otherConstraints/gco:mcoCharacterString = \"LicenseUrl:\"",
    "UseConstraints/LicenseText" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints/mco:MD_LegalConstraints/mco:useConstraints/mco:MD_RestrictionCode codeList \"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_RestrictionCode\" codeListValue \"otherRestrictions\" =  \"otherRestrictions\"
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints/mco:MD_LegalConstraints/mco:otherConstraints/gco:mcoCharacterString = \"LicenseText:\"",
    "AccessConstraints" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints/mco:MD_LegalConstraints/ [=>",
    "AccessConstraints/Description" => "[=> mco:accessConstriants/mco:MD_RestrictionCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_RestrictionCode\" codeListValue=\"otherRestrictions\"=otherRestrictions
[=> mco:otherConstraints/gco:CharacterString (prefix:'Access Constraints Description:')",
    "AccessConstraints/Value" => "[=> mco:accessConstriants/mco:MD_RestrictionCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_RestrictionCode\" codeListValue=\"otherRestrictions\"=otherRestrictions
[=> mco:otherConstraints/gco:CharacterString (prefix:'Access Constraints Value:')",
    "MetadataAssociation/EntryId" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:associatedResource/mri:MD_AssociatedResource/mri:name
Metadata Associations:
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:associatedResource/mri:MD_AssociatedResource/mri:associationType/mri:DS_AssociationTypeCode codeList=\"codeListLocation#DS_AssociationTypeCode\"codeListValue=\"Science Associated\"
Parent Associations:
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:associatedResource/mri:MD_AssociatedResource/mri:associationType/mri:DS_AssociationTypeCode codeList=\"codeListLocation#DS_AssociationTypeCode\"codeListValue=\"largerWorkCitation\"",
    "PublicationReferences" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:additionalDocumentation/",
    "PublicationReferences/Author" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/
cit:CI_Individual/cit:name or cit:CI_Organization/cit:name
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:role/cit:CI_RoleCode=author",
    "PublicationReferences/Title" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:title",
    "PublicationReferences/Series" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:series/cit:CI_Series/cit:name",
    "PublicationReferences/Edition" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:edition",
    "PublicationReferences/ISBN" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:ISBN",
    "PublicationReferences/DOI" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/",
    "PublicationReferences/DOI/Authority" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/
cit:CI_Individual/cit:name or cit:CI_Organization/cit:name",
    "PublicationReferences/DOI/DOI" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString
where
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:description/gco:CharacterString = DOI
and
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:codeSpace = gov.nasa.esdis.umm.doi",
    "ISOTopicCategories" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:topicCategory/mri:MD_TopicCategoryCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_TopicCategoryCode\" codeListValue=\"{value}\">{value}",
    "ScienceKeywords" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords
write only:
If any keyword is missing and there exists a keyword later in the hierarchy (such as DetailedLocation), use NONE to fill in the values in between.
read only: don't use if a value = NONE.
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword",
    "ScienceKeywords/Category" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString  ( The first value - delimited by &gt; )
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"theme\"",
    "ScienceKeywords/Topic" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString  ( The second value - delimited by &gt; )
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"theme\"",
    "ScienceKeywords/Term" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString  ( The third value - delimited by &gt; )
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"theme\"",
    "ScienceKeywords/VariableLevel1" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString  ( The fourth value - delimited by &gt; )
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"theme\"",
    "ScienceKeywords/VariableLevel2" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString  ( The fifth value - delimited by &gt; )
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"theme\"",
    "ScienceKeywords/VariableLevel3" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString  ( The sixth value - delimited by &gt; )
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"theme\"",
    "ScienceKeywords/DetailedVariable" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString  ( The sixth value - delimited by &gt; )
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"theme\"",
    "AncillaryKeywords" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString",
    "AdditionalAttributes" => "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute",
    "AdditionalAttributes/Name" => "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:name/gco:CharacterString",
    "AdditionalAttributes/Type" => "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:type/eos:EOS_AdditionalAttributeTypeCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/eosCodelists.xml#EOS_AdditionalAttributeTypeCode\" codeListValue=\"*type*\">*type*
  where *type* = processingInformation",
    "AdditionalAttributes/Identifier" => "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString",
    "AdditionalAttributes/DataType" => "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:dataType/eos:EOS_AdditionalAttributeDataTypeCode codeList=\"http://earthdata.nasa.gov/metadata/resources/Codelists.xml#EOS_AdditionalAttributeDataTypeCode\" codeListValue=\"*dataType*\">*dataType*</eos:EOS_AdditionalAttributeDataTypeCode>
  where *dataType* = STRING,FLOAT,INT, etc.",
    "AdditionalAttributes/Description" => "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:description/gco:CharacterString",
    "AdditionalAttributes/MeasurementResolution" => "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:measurementResolution/gco:CharacterString",
    "AdditionalAttributes/ParameterRangeBegin" => "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:parameterRangeBegin/gco:CharacterString",
    "AdditionalAttributes/ParameterRangeEnd" => "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:parameterRangeEnd/gco:CharacterString",
    "AdditionalAttributes/ParameterUnitsOfMeasure" => "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:parameterUnitsOfMeasure/gco:CharacterString",
    "AdditionalAttributes/ParameterValueAccuracy" => "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:parameterValueAccuracy/gco:CharacterString",
    "AdditionalAttributes/ValueAccuracyExplanation" => "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:reference/eos:EOS_AdditionalAttributeDescription/eos:valueAccuracyExplanation/gco:CharacterString",
    "AdditionalAttributes/Value" => "/mdb:MD_Metadata/mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mil:LE_Source/mrl:processStep/mil:LE_ProcessStep/mrl:processor/mil:processingInformation/eos:EOS_Processing/eos:otherProperty/gco:Record/eos:AdditionalAttributes/eos:AdditionalAttribute/eos:value/gco:CharacterString",
    "TemporalExtents" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent",
    "TemporalExtents/TemporalRangeType" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:description/gco:CharacterString DateType=",
    "TemporalExtents/PrecisionOfSeconds" => "/mdb:MD_Metadata/mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_AccuracyOfATimeMeasurement/mdq:measure/mdq:DQ_MeasureReference/mdq:measureIdentification/mcc:MD_Identifier/mcc:code/gco:CharacterString =  PrecisionOfSeconds
and
/mdb:MD_Metadata/mdb:dataQualityInfo/mdq:DQ_DataQuality/mdq:report/mdq:DQ_AccuracyOfATimeMeasurement/mdq:result/mdq:DQ_QuantitativeResult/mdq:value/gco:Record xsi:type=\"gco:Real_PropertyType\"/gco:Real   PrecisionOfSeconds Value",
    "TemporalExtents/EndsAtPresentFlag" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:endPosition indeterminatePosition=\"now\"",
    "TemporalExtents/RangeDateTime/BeginningDateTime" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:beginPosition",
    "TemporalExtents/RangeDateTime/EndingDateTime" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/gml:TimePeriod/gml:endPosition",
    "TemporalExtents/SingleDateTimes" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent/gex:extent/ gml:TimeInstant/gml:timePosition",
    "TemporalKeywords" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:type/mri:MD_KeywordTypeCode[@codeListValue=\"temporal\"]",
    "SpatialExtent" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent[@id='boundingExtent'] [=>
Create a new gmd:extent - do not share with TilingInformationSystem",
    "SpatialExtent/SpatialCoverageType" => "[=>/gex:description/gco:CharacterString SpatialCoverageType=",
    "SpatialExtent/HorizontaSpatialDomain/ZoneIdentifier" => "[=>/gex:geographicElement/gex:EX_GeographicDescription/gex:geographicIdentifier/mcc:MD_Identifier/mcc:code/gco:CharacterString
with
[=>/gex:geographicElement/gex:EX_GeographicDescription/gex:geographicIdentifier/mcc:MD_Identifier/mcc:description/gco:CharacterString = ZoneIdentifier",
    "SpatialExtent/HorizontaSpatialDomain/Geometry/BoundingRectangles/WestBoundingCoordinate" => "[=>/gex:geographicElement/gex:EX_GeographicBoundingBox/gex:westBoundLongitude/gco:Decimal",
    "SpatialExtent/HorizontaSpatialDomain/Geometry/BoundingRectangles/NorthBoundingCoordinate" => "[=>/gex:geographicElement/gex:EX_GeographicBoundingBox/gex:northBoundLongitude/gco:Decimal",
    "SpatialExtent/HorizontaSpatialDomain/Geometry/BoundingRectangles/EastBoundingCoordinate" => "[=>/gex:geographicElement/gex:EX_GeographicBoundingBox/gex:eastBoundLongitude/gco:Decimal",
    "SpatialExtent/HorizontaSpatialDomain/Geometry/BoundingRectangles/SouthBoundingCoordinate" => "[=>/gex:geographicElement/gex:EX_GeographicBoundingBox/gex:southBoundLongitude/gco:Decimal",
    "SpatialExtent/VerticalSpatialDomain" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent[@id='boundingExtent']/gex:description/gco:CharacterString
with format:
VerticalSpatialDomainType= {type}, VerticalSpatialDomainValue= {value}",
    "SpatialExtent/VerticalSpatialDomain/Type" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent[@id='boundingExtent']/gex:description/gco:CharacterString
with format:
VerticalSpatialDomainType= {type}, VerticalSpatialDomainValue= {value}",
    "SpatialExtent/VerticalSpatialDomain/Value" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent[@id='boundingExtent']/gex:description/gco:CharacterString
with format:
VerticalSpatialDomainType= {type}, VerticalSpatialDomainValue= {value}",
    "SpatialExtent/VerticalSpatialDomain/Unit" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent[@id='boundingExtent']/gex:description/gco:CharacterString
with format:
VerticalSpatialDomainType= {type}, VerticalSpatialDomainValue= {value}",
    "SpatialExtent/GranuleSpatialRepresentation" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/gex:EX_Extent[@id='boundingExtent']/gex:description/gco:CharacterString SpatialGranuleSpatialRepresentation=",
    "LocationKeywords" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords [=>
write only:
If any keyword is missing and there exists a keyword later in the hierarchy (such as DetailedLocation), use NONE to fill in the values in between.
read only: don't use if a value = NONE.
[=>/mri:keyword",
    "LocationKeywords/Category" => "[=>/mri:keyword/gco:CharacterString  ( The first value - delimited by &gt; )
with
[=>/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"place\"",
    "LocationKeywords/Type" => "[=>/mri:keyword/gco:CharacterString  ( The second value - delimited by &gt; )
with
[=>/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"place\"",
    "LocationKeywords/Subregion1" => "[=>/mri:keyword/gco:CharacterString  ( The third value - delimited by &gt; )
with
[=>/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"place\"",
    "LocationKeywords/Subregion2" => "[=>/mri:keyword/gco:CharacterString  ( The fourth value - delimited by &gt; )
with
[=>/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"place\"",
    "LocationKeywords/Subregion3" => "[=>/mri:keyword/gco:CharacterString  ( The fifth value - delimited by &gt; )
with
[=>/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"place\"",
    "LocationKeywords/DetailedLocation" => "[=>/mri:keyword/gco:CharacterString  ( The sixth value - delimited by &gt; )
with
[=>/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode codeListValue=\"place\"",
    "Platforms" => "/mdb:MD_Metadata/mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:platform/mac:MI_Platform id=",
    "Platforms/ShortName" => "/mdb:MD_Metadata/mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:platform/mac:MI_Platform id="..."/mac:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString
and
(CMR write only)
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode\" ListValue=\"platform\"",
    "Platforms/Instruments" => "/mdb:MD_Metadata/mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:instrument/mac:MI_Instrument id=",
    "Platforms/Instruments/ShortName" => "/mdb:MD_Metadata/mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:instrument/mac:MI_Instrument id="..."/mac:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString
and
(CMR write only)
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode\" codeListValue=\"instrument\"",
    "Platforms/Instruments/ComposedOf/ShortName" => "/mdb:MD_Metadata/mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:instrument/mac:MI_Instrument id="..."/mac:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString
and
(CMR write only)
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=\"https://cdn.earthdata.nasa.gov/iso/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode\" codeListValue=\"instrument\"",
    "Projects" => "/mdb:MD_Metadata/mdb:acquisitionInformation/mac:MI_AcquisitionInformation/mac:operation/mac:MI_Operation/ [=>",
    "Projects/ShortName" => "[=>mac:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString
[=>mac:identifier/mcc:MD_Identifier/mcc:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.projectshortname
and (CMR write only)
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/gco:CharacterString
with
/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword/mri:type/mri:MD_KeywordTypeCode codeList=\"http://www.ngdc.noaa.gov/metadata/published/xsd/schema/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode\" codeListValue=\"project\"",
    "Projects/LongName" => "[=> mac:identifier/mcc:MD_Identifier/mcc:description/gco:CharacterString",
    "Projects/Campaigns" => "[=> mac:childOperation/mac:MI_Operation/mac:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString
with
[=> mac:childOperation/mac:MI_Operation/mac:identifier/mcc:MD_Identifier/mcc:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.campaignshortname",
    "Projects/StartDate" => "[=>/mac:description/gco:CharacterString StartDate:",
    "Projects/EndDate" => "[=>/mac:description/gco:CharacterString EndDate:",
    "Maturity" => "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/ [=>
[=> mcc:code/gco:CharacterString
and
[=>gmd:codeSpace/gco:CharacterString = gov.nasa.esdis.umm.maturity
and
[=> gmd:description/gco:CharacterString = Maturity"
  }.freeze
end