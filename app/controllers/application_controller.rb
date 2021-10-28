class ApplicationController < ActionController::API
  private

  def result_limit
    params.fetch(:per_page, 20).to_i
  end

  def page_offset
    page = params.fetch(:page, 1).to_i
    page = 1 if page < 1
    (page - 1) * result_limit
  end
end
