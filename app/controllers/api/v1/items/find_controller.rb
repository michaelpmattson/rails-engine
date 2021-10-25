class Api::V1::Items::FindController < ApplicationController
  def index
    if params[:name] && price_query?
      render json: { error: 'Sorry, cannot query both name and price.' }, status: 400
    elsif params[:name]
      items = Item.find_all_by_name(params[:name])
      render json: ItemSerializer.new(items)
    elsif price_query?
      items = Item.find_all_by_price(price_params)
      render json: ItemSerializer.new(items)
    else
    end
  end

  private

  def price_query?
    params[:min_price] || params[:max_price]
  end

  def price_params
    params.permit(:min_price, :max_price)
  end
end
