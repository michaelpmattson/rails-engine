class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def not_found(error)
    render json: { error: error.message }, status: 404
  end

  def result_limit
    params.fetch(:per_page, 20).to_i
  end

  def page_offset
    page = params.fetch(:page, 1).to_i
    page = 1 if page < 1
    (page - 1) * result_limit
  end
end
