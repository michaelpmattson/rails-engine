class Api::V1::Items::MerchantController < ApplicationController
  def show
    item = Item.find(params[:item_id])
    render json: MerchantSerializer.new(item.merchant)

  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Sorry, that item does not exist' }, status: 404
  end
end
