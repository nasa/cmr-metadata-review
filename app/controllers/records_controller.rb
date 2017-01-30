class RecordsController < ApplicationController
  def show
    record = Record.find_by id: params["id"]
    @bubble_data = record.section_bubble_data(0)

    @long_name = record.long_name
    @short_name = record.short_name
  end

end