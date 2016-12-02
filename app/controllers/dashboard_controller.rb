class DashboardController < ApplicationController
  def index
    path = Rails.root.join('vendor', 'webpack-assets.json')
    file = File.read(path)
    @assets_container = JSON.parse(file)
  end
end