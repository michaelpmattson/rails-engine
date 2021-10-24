class Api::V1::ItemsController < ApplicationController
  def index
    items = Item.limit(item_limit).offset(item_offset)
    render json: ItemSerializer.new(items)
  end

  def show
    item = Item.find(params[:id])
    render json: ItemSerializer.new(item)
  end

  def create
    render json: Item.create(item_params)
  end

  def update
    render json: Item.update(item_params)
  end

  def destroy

  end

  private

  def item_limit
    params.fetch(:per_page, 20).to_i
  end

  def item_offset
    page = params.fetch(:page, 1).to_i
    page = 1 if page < 1
    (page - 1) * item_limit
  end

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end
