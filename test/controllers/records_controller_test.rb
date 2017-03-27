class RecordsControllerTest < ActionController::TestCase

  describe "POST #create" do  
      it "updates record data from review params" do
        @tester = User.find_by_email("abaker@element84.com")
        sign_in(@tester)
        #sample update params
        #posting with a record id param of 1
        post :update, {"redirect_index"=>"0", "flag"=>{"ShortName"=>{"Usability"=>"on", "Traceability"=>"on"}, "InsertTime"=>{"Accessibility"=>"on"}, "LastUpdate"=>{"Usability"=>"on"}}, "recommendation"=>{"ShortName"=>"", "VersionId"=>"not ok", "InsertTime"=>"ok", "LastUpdate"=>"ok", "LongName"=>"", "DataSetId"=>"", "Description"=>"", "CollectionDataType"=>"", "Orderable"=>"", "Visible"=>"", "ProcessingLevelId"=>"", "ArchiveCenter"=>"", "CitationForExternalPublication"=>"", "Price"=>"", "SpatialKeywords/Keyword"=>"", "TemporalKeywords/Keyword"=>"", "AssociatedDIFs/DIF/EntryId"=>"", "MetadataStandardName"=>"", "MetadataStandardVersion"=>"", "DatasetId"=>"", "DataFormat"=>""}, "opinion"=>{"InsertTime"=>"on"}, "color_code"=>{"ShortName"=>"", "VersionId"=>"red", "InsertTime"=>"green", "LastUpdate"=>"green", "LongName"=>"", "DataSetId"=>"", "Description"=>"", "CollectionDataType"=>"", "Orderable"=>"", "Visible"=>"", "ProcessingLevelId"=>"", "ArchiveCenter"=>"", "CitationForExternalPublication"=>"", "Price"=>"", "SpatialKeywords/Keyword"=>"", "TemporalKeywords/Keyword"=>"", "AssociatedDIFs/DIF/EntryId"=>"", "MetadataStandardName"=>"", "MetadataStandardVersion"=>"", "DatasetId"=>"", "DataFormat"=>""}, "discussion"=>{"ShortName"=>"", "VersionId"=>"", "InsertTime"=>"", "LastUpdate"=>"", "LongName"=>"new comment", "DataSetId"=>"", "Description"=>"", "CollectionDataType"=>"", "Orderable"=>"", "Visible"=>"", "ProcessingLevelId"=>"", "ArchiveCenter"=>"", "CitationForExternalPublication"=>"", "Price"=>"", "SpatialKeywords/Keyword"=>"", "TemporalKeywords/Keyword"=>"", "AssociatedDIFs/DIF/EntryId"=>"", "MetadataStandardName"=>"", "MetadataStandardVersion"=>"", "DatasetId"=>"", "DataFormat"=>""}, "utf8"=>"✓", "_method"=>"put", "authenticity_token"=>"rKpXaDgn6x9I1T3gNZ4cpEYZZsWORy4gnLAPTNsZIaRWxFWRM6trFGVDe8BkL8kklhC00LikvGn1Uau2KAA4fg==", "section_index"=>"0", "commit"=>"Save Review", "controller"=>"records", "action"=>"update", "id"=>"1"}


        record = Record.find_by id: 1
        #broken out sections of params below to compare to tests
        #all positive tests, making sure that desired additions appear


        #"flag"=>{"ShortName"=>{"Usability"=>"on", "Traceability"=>"on"}, "InsertTime"=>{"Accessibility"=>"on"}, "LastUpdate"=>{"Usability"=>"on"}}
        assert_equal(record.get_flags.values["ShortName"], ["Usability", "Traceability"])
        assert_equal(record.get_flags.values["InsertTime"], ["Accessibility"])
        assert_equal(record.get_flags.values["LastUpdate"], ["Usability"])

        #"recommendation"=>{"ShortName"=>"", "VersionId"=>"not ok", "InsertTime"=>"ok", "LastUpdate"=>"ok", "LongName"=>"", "DataSetId"=>"", "Description"=>"", "CollectionDataType"=>"", "Orderable"=>"", "Visible"=>"", "ProcessingLevelId"=>"", "ArchiveCenter"=>"", "CitationForExternalPublication"=>"", "Price"=>"", "SpatialKeywords/Keyword"=>"", "TemporalKeywords/Keyword"=>"", "AssociatedDIFs/DIF/EntryId"=>"", "MetadataStandardName"=>"", "MetadataStandardVersion"=>"", "DatasetId"=>"", "DataFormat"=>""}
        assert_equal(record.get_recommendations.values["VersionId"], "not ok")
        assert_equal(record.get_recommendations.values["InsertTime"], "ok")
        assert_equal(record.get_recommendations.values["LastUpdate"], "ok")

        #"opinion"=>{"InsertTime"=>"on"}
        assert_equal(record.get_opinions.values["InsertTime"], true)      

        #"color_code"=>{"ShortName"=>"", "VersionId"=>"red", "InsertTime"=>"green", "LastUpdate"=>"green", "LongName"=>"", "DataSetId"=>"", "Description"=>"", "CollectionDataType"=>"", "Orderable"=>"", "Visible"=>"", "ProcessingLevelId"=>"", "ArchiveCenter"=>"", "CitationForExternalPublication"=>"", "Price"=>"", "SpatialKeywords/Keyword"=>"", "TemporalKeywords/Keyword"=>"", "AssociatedDIFs/DIF/EntryId"=>"", "MetadataStandardName"=>"", "MetadataStandardVersion"=>"", "DatasetId"=>"", "DataFormat"=>""}
        assert_equal(record.get_colors.values["VersionId"], "red")
        assert_equal(record.get_colors.values["InsertTime"], "green")
        assert_equal(record.get_colors.values["LastUpdate"], "green")


        #"discussion"=>{"ShortName"=>"", "VersionId"=>"", "InsertTime"=>"", "LastUpdate"=>"", "LongName"=>"new comment", "DataSetId"=>"", "Description"=>"", "CollectionDataType"=>"", "Orderable"=>"", "Visible"=>"", "ProcessingLevelId"=>"", "ArchiveCenter"=>"", "CitationForExternalPublication"=>"", "Price"=>"", "SpatialKeywords/Keyword"=>"", "TemporalKeywords/Keyword"=>"", "AssociatedDIFs/DIF/EntryId"=>"", "MetadataStandardName"=>"", "MetadataStandardVersion"=>"", "DatasetId"=>"", "DataFormat"=>""}
        assert_equal(record.discussions.where(column_name: "LongName").sort_by(&:date).first.comment, "new comment")      

      end


      it "removes values when unselected" do
        @tester = User.find_by_email("abaker@element84.com")
        sign_in(@tester)

        #using the same post data from update record test
        post :update, {"redirect_index"=>"0", "flag"=>{"ShortName"=>{"Usability"=>"on", "Traceability"=>"on"}, "InsertTime"=>{"Accessibility"=>"on"}, "LastUpdate"=>{"Usability"=>"on"}}, "recommendation"=>{"ShortName"=>"", "VersionId"=>"not ok", "InsertTime"=>"ok", "LastUpdate"=>"ok", "LongName"=>"", "DataSetId"=>"", "Description"=>"", "CollectionDataType"=>"", "Orderable"=>"", "Visible"=>"", "ProcessingLevelId"=>"", "ArchiveCenter"=>"", "CitationForExternalPublication"=>"", "Price"=>"", "SpatialKeywords/Keyword"=>"", "TemporalKeywords/Keyword"=>"", "AssociatedDIFs/DIF/EntryId"=>"", "MetadataStandardName"=>"", "MetadataStandardVersion"=>"", "DatasetId"=>"", "DataFormat"=>""}, "opinion"=>{"InsertTime"=>"on"}, "color_code"=>{"ShortName"=>"", "VersionId"=>"red", "InsertTime"=>"green", "LastUpdate"=>"green", "LongName"=>"", "DataSetId"=>"", "Description"=>"", "CollectionDataType"=>"", "Orderable"=>"", "Visible"=>"", "ProcessingLevelId"=>"", "ArchiveCenter"=>"", "CitationForExternalPublication"=>"", "Price"=>"", "SpatialKeywords/Keyword"=>"", "TemporalKeywords/Keyword"=>"", "AssociatedDIFs/DIF/EntryId"=>"", "MetadataStandardName"=>"", "MetadataStandardVersion"=>"", "DatasetId"=>"", "DataFormat"=>""}, "discussion"=>{"ShortName"=>"", "VersionId"=>"", "InsertTime"=>"", "LastUpdate"=>"", "LongName"=>"new comment", "DataSetId"=>"", "Description"=>"", "CollectionDataType"=>"", "Orderable"=>"", "Visible"=>"", "ProcessingLevelId"=>"", "ArchiveCenter"=>"", "CitationForExternalPublication"=>"", "Price"=>"", "SpatialKeywords/Keyword"=>"", "TemporalKeywords/Keyword"=>"", "AssociatedDIFs/DIF/EntryId"=>"", "MetadataStandardName"=>"", "MetadataStandardVersion"=>"", "DatasetId"=>"", "DataFormat"=>""}, "utf8"=>"✓", "_method"=>"put", "authenticity_token"=>"rKpXaDgn6x9I1T3gNZ4cpEYZZsWORy4gnLAPTNsZIaRWxFWRM6trFGVDe8BkL8kklhC00LikvGn1Uau2KAA4fg==", "section_index"=>"0", "commit"=>"Save Review", "controller"=>"records", "action"=>"update", "id"=>"1"}

        #now posting new empty params to clear choices
        post :update, {"redirect_index"=>"0", "flag"=>{}, "recommendation"=>{"ShortName"=>"", "VersionId"=>"", "InsertTime"=>"", "LastUpdate"=>"", "LongName"=>"", "DataSetId"=>"", "Description"=>"", "CollectionDataType"=>"", "Orderable"=>"", "Visible"=>"", "ProcessingLevelId"=>"", "ArchiveCenter"=>"", "CitationForExternalPublication"=>"", "Price"=>"", "SpatialKeywords/Keyword"=>"", "TemporalKeywords/Keyword"=>"", "AssociatedDIFs/DIF/EntryId"=>"", "MetadataStandardName"=>"", "MetadataStandardVersion"=>"", "DatasetId"=>"", "DataFormat"=>""}, "opinion"=>{}, "color_code"=>{"ShortName"=>"", "VersionId"=>"", "InsertTime"=>"", "LastUpdate"=>"", "LongName"=>"", "DataSetId"=>"", "Description"=>"", "CollectionDataType"=>"", "Orderable"=>"", "Visible"=>"", "ProcessingLevelId"=>"", "ArchiveCenter"=>"", "CitationForExternalPublication"=>"", "Price"=>"", "SpatialKeywords/Keyword"=>"", "TemporalKeywords/Keyword"=>"", "AssociatedDIFs/DIF/EntryId"=>"", "MetadataStandardName"=>"", "MetadataStandardVersion"=>"", "DatasetId"=>"", "DataFormat"=>""}, "discussion"=>{"ShortName"=>"", "VersionId"=>"", "InsertTime"=>"", "LastUpdate"=>"", "LongName"=>"", "DataSetId"=>"", "Description"=>"", "CollectionDataType"=>"", "Orderable"=>"", "Visible"=>"", "ProcessingLevelId"=>"", "ArchiveCenter"=>"", "CitationForExternalPublication"=>"", "Price"=>"", "SpatialKeywords/Keyword"=>"", "TemporalKeywords/Keyword"=>"", "AssociatedDIFs/DIF/EntryId"=>"", "MetadataStandardName"=>"", "MetadataStandardVersion"=>"", "DatasetId"=>"", "DataFormat"=>""}, "utf8"=>"✓", "_method"=>"put", "authenticity_token"=>"rKpXaDgn6x9I1T3gNZ4cpEYZZsWORy4gnLAPTNsZIaRWxFWRM6trFGVDe8BkL8kklhC00LikvGn1Uau2KAA4fg==", "section_index"=>"0", "commit"=>"Save Review", "controller"=>"records", "action"=>"update", "id"=>"1"}

        record = Record.find_by id: 1
        #broken out sections of params below to compare to tests
        #all positive tests, making sure that desired additions appear

        assert_equal(record.get_flags.values["ShortName"], [])
        assert_equal(record.get_flags.values["InsertTime"], [])
        assert_equal(record.get_flags.values["LastUpdate"], [])

        assert_equal(record.get_recommendations.values["VersionId"], "")
        assert_equal(record.get_recommendations.values["InsertTime"], "")
        assert_equal(record.get_recommendations.values["LastUpdate"], "")

        assert_equal(record.get_opinions.values["InsertTime"], false)      

        assert_equal(record.get_colors.values["VersionId"], "")
        assert_equal(record.get_colors.values["InsertTime"], "")
        assert_equal(record.get_colors.values["LastUpdate"], "")

        #discussion should not be changed, checking to ensure its still there.
        assert_equal(record.discussions.where(column_name: "LongName").sort_by(&:date).first.comment, "new comment")      

      end

  end

end