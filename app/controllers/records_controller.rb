class RecordsController < ApplicationController
  def show
    record = Record.find_by id: params["id"]
    @bubble_data = record.section_bubble_data(Record::COLLECTION_INFORMATION_FIELDS)
  end

end