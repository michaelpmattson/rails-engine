class Api::V1::ItemsController < ApplicationController
  def index
    items = Item.limit(result_limit).offset(page_offset)
    render json: ItemSerializer.new(items)
  end

  def show
    item = Item.find(params[:id])
    render json: ItemSerializer.new(item)
  end

  def create
    item = Item.create(item_params)
    render json: ItemSerializer.new(item), status: 201
  end

  def update
    item     = Item.find(params[:id])

    if item.update(item_params)
      render json: ItemSerializer.new(item)
    elsif item.merchant.nil?
      render json: { error: "Couldn't find Merchant with 'id'=#{item_params[:merchant_id]}" }, status: 404
    end
  end

  def destroy
    render json: Item.delete(params[:id])
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end
