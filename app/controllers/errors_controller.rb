class ErrorsController < ApplicationController
  # https://stackoverflow.com/questions/21654826/how-to-rescue-page-not-found-404-in-rails
  def routing
    render_404
  end
end