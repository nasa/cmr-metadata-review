require 'test_helper'

class RecordsControllerTest < ActionController::TestCase
  describe "POST #create" do  
    it "updates record data from review params" do
      @tester = User.find_by_email("abaker@element84.com")
      sign_in(@tester)
      #sample update params
      #posting with a record id param of 1       
      post :update, {"redirect_index"=>"0", "recommendation"=>{"ShortName"=>"", "VersionId"=>"not ok", "LongName"=>"ok"}, "opinion"=>{"VersionId"=>"on"}, "color_code"=>{"ShortName"=>"", "VersionId"=>"red", "LongName"=>""}, "discussion"=>{"ShortName"=>"", "VersionId"=>"", "LongName"=>"new comment"}, "utf8"=>"✓", "_method"=>"put", "authenticity_token"=>"rKpXaDgn6x9I1T3gNZ4cpEYZZsWORy4gnLAPTNsZIaRWxFWRM6trFGVDe8BkL8kklhC00LikvGn1Uau2KAA4fg==", "section_index"=>"0", "commit"=>"Save Review", "controller"=>"records", "action"=>"update", "id"=>"1"}

      record = Record.find_by id: 1
      #broken out sections of params below to compare to tests
      #all positive tests, making sure that desired additions appear

      assert_equal(record.get_recommendations["VersionId"], "not ok")
      assert_equal(record.get_recommendations["ShortName"], "")
      assert_equal(record.get_recommendations["LongName"], "ok")

      assert_equal(record.get_opinions["VersionId"], true)      

      assert_equal(record.get_colors["VersionId"], "red")
      assert_equal(record.get_colors["ShortName"], "")
      assert_equal(record.get_colors["LongName"], "")


      #"discussion"=>{"ShortName"=>"", "VersionId"=>"", "InsertTime"=>"", "LastUpdate"=>"", "LongName"=>"new comment", "DataSetId"=>"", "Description"=>"", "CollectionDataType"=>"", "Orderable"=>"", "Visible"=>"", "ProcessingLevelId"=>"", "ArchiveCenter"=>"", "CitationForExternalPublication"=>"", "Price"=>"", "SpatialKeywords/Keyword"=>"", "TemporalKeywords/Keyword"=>"", "AssociatedDIFs/DIF/EntryId"=>"", "MetadataStandardName"=>"", "MetadataStandardVersion"=>"", "DatasetId"=>"", "DataFormat"=>""}
      assert_equal(record.discussions.where(column_name: "LongName").sort_by(&:date).first.comment, "new comment")      
    end

    it "removes values when unselected" do
      @tester = User.find_by_email("abaker@element84.com")
      sign_in(@tester)

      #using the same post data from update record test
      post :update, {"redirect_index"=>"0", "recommendation"=>{"ShortName"=>"", "VersionId"=>"not ok", "InsertTime"=>"ok", "LastUpdate"=>"ok", "LongName"=>"", "DataSetId"=>"", "Description"=>"", "CollectionDataType"=>"", "Orderable"=>"", "Visible"=>"", "ProcessingLevelId"=>"", "ArchiveCenter"=>"", "CitationForExternalPublication"=>"", "Price"=>"", "SpatialKeywords/Keyword"=>"", "TemporalKeywords/Keyword"=>"", "AssociatedDIFs/DIF/EntryId"=>"", "MetadataStandardName"=>"", "MetadataStandardVersion"=>"", "DatasetId"=>"", "DataFormat"=>""}, "opinion"=>{"InsertTime"=>"on"}, "color_code"=>{"ShortName"=>"", "VersionId"=>"red", "InsertTime"=>"green", "LastUpdate"=>"green", "LongName"=>"", "DataSetId"=>"", "Description"=>"", "CollectionDataType"=>"", "Orderable"=>"", "Visible"=>"", "ProcessingLevelId"=>"", "ArchiveCenter"=>"", "CitationForExternalPublication"=>"", "Price"=>"", "SpatialKeywords/Keyword"=>"", "TemporalKeywords/Keyword"=>"", "AssociatedDIFs/DIF/EntryId"=>"", "MetadataStandardName"=>"", "MetadataStandardVersion"=>"", "DatasetId"=>"", "DataFormat"=>""}, "discussion"=>{"ShortName"=>"", "VersionId"=>"", "InsertTime"=>"", "LastUpdate"=>"", "LongName"=>"new comment", "DataSetId"=>"", "Description"=>"", "CollectionDataType"=>"", "Orderable"=>"", "Visible"=>"", "ProcessingLevelId"=>"", "ArchiveCenter"=>"", "CitationForExternalPublication"=>"", "Price"=>"", "SpatialKeywords/Keyword"=>"", "TemporalKeywords/Keyword"=>"", "AssociatedDIFs/DIF/EntryId"=>"", "MetadataStandardName"=>"", "MetadataStandardVersion"=>"", "DatasetId"=>"", "DataFormat"=>""}, "utf8"=>"✓", "_method"=>"put", "authenticity_token"=>"rKpXaDgn6x9I1T3gNZ4cpEYZZsWORy4gnLAPTNsZIaRWxFWRM6trFGVDe8BkL8kklhC00LikvGn1Uau2KAA4fg==", "section_index"=>"0", "commit"=>"Save Review", "controller"=>"records", "action"=>"update", "id"=>"1"}

      #now posting new empty params to clear choices
      post :update, {"redirect_index"=>"0", "recommendation"=>{"ShortName"=>"", "VersionId"=>"", "InsertTime"=>"", "LastUpdate"=>"", "LongName"=>"", "DataSetId"=>"", "Description"=>"", "CollectionDataType"=>"", "Orderable"=>"", "Visible"=>"", "ProcessingLevelId"=>"", "ArchiveCenter"=>"", "CitationForExternalPublication"=>"", "Price"=>"", "SpatialKeywords/Keyword"=>"", "TemporalKeywords/Keyword"=>"", "AssociatedDIFs/DIF/EntryId"=>"", "MetadataStandardName"=>"", "MetadataStandardVersion"=>"", "DatasetId"=>"", "DataFormat"=>""}, "opinion"=>{}, "color_code"=>{"ShortName"=>"", "VersionId"=>"", "InsertTime"=>"", "LastUpdate"=>"", "LongName"=>"", "DataSetId"=>"", "Description"=>"", "CollectionDataType"=>"", "Orderable"=>"", "Visible"=>"", "ProcessingLevelId"=>"", "ArchiveCenter"=>"", "CitationForExternalPublication"=>"", "Price"=>"", "SpatialKeywords/Keyword"=>"", "TemporalKeywords/Keyword"=>"", "AssociatedDIFs/DIF/EntryId"=>"", "MetadataStandardName"=>"", "MetadataStandardVersion"=>"", "DatasetId"=>"", "DataFormat"=>""}, "discussion"=>{"ShortName"=>"", "VersionId"=>"", "InsertTime"=>"", "LastUpdate"=>"", "LongName"=>"", "DataSetId"=>"", "Description"=>"", "CollectionDataType"=>"", "Orderable"=>"", "Visible"=>"", "ProcessingLevelId"=>"", "ArchiveCenter"=>"", "CitationForExternalPublication"=>"", "Price"=>"", "SpatialKeywords/Keyword"=>"", "TemporalKeywords/Keyword"=>"", "AssociatedDIFs/DIF/EntryId"=>"", "MetadataStandardName"=>"", "MetadataStandardVersion"=>"", "DatasetId"=>"", "DataFormat"=>""}, "utf8"=>"✓", "_method"=>"put", "authenticity_token"=>"rKpXaDgn6x9I1T3gNZ4cpEYZZsWORy4gnLAPTNsZIaRWxFWRM6trFGVDe8BkL8kklhC00LikvGn1Uau2KAA4fg==", "section_index"=>"0", "commit"=>"Save Review", "controller"=>"records", "action"=>"update", "id"=>"1"}

      record = Record.find_by id: 1
      #broken out sections of params below to compare to tests
      #all positive tests, making sure that desired additions appear

      assert_equal(record.get_recommendations["VersionId"], "")
      assert_equal(record.get_recommendations["ShortName"], "")
      assert_equal(record.get_recommendations["LongName"], "")

      assert_equal(record.get_opinions["VersionId"], false)      

      assert_equal(record.get_colors["VersionId"], "")
      assert_equal(record.get_colors["ShortName"], "")
      assert_equal(record.get_colors["LongName"], "")

      #discussion should not be changed, checking to ensure its still there.
      assert_equal(record.discussions.where(column_name: "LongName").sort_by(&:date).first.comment, "new comment")      
    end
  end
end
