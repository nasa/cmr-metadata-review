class RecordsController < ApplicationController
  def show
    record = Record.find_by id: params["id"]
    @bubble_data = record.section_bubble_data(0)
  end

end