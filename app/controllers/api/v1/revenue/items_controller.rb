class Api::V1::Revenue::ItemsController < ApplicationController
  def index
    if params[:quantity].nil?
      item_revenues = Item.sort_by_revenue(10)
      render json: ItemRevenueSerializer.new(item_revenues)
    elsif !integer?(params[:quantity])
      render json: { error: 'Sorry, quantity must be integer' }, status: 400
    elsif params[:quantity].to_i < 1
      render json: { error: 'Sorry, quantity must be greater than zero' }, status: 400
    else
      item_revenues = Item.sort_by_revenue(params[:quantity])
      render json: ItemRevenueSerializer.new(item_revenues)
    end
  end

  private

  def integer?(param)
    param.to_i.to_s == param
  end
end
