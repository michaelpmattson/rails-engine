class Api::V1::Merchants::MostItemsController < ApplicationController
  def index
    if params[:quantity].nil?
      render json: { error: 'Sorry, quantity must exist' }, status: 400
    elsif !integer?(params[:quantity])
      render json: { error: 'Sorry, quantity must be integer' }, status: 400
    elsif params[:quantity].to_i < 1
      render json: { error: 'Sorry, quantity must be greater than zero' }, status: 400
    else
      merchants = Merchant.sort_by_items_sold(params[:quantity])
      render json: ItemsSoldSerializer.format_items_sold(merchants)
    end
  end

  private

  def integer?(param)
    param.to_i.to_s == param
  end
end
