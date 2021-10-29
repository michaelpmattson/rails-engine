class Api::V1::MerchantsController < ApplicationController
  def index
    merchants = Merchant.limit(result_limit).offset(page_offset)
    render json: MerchantSerializer.new(merchants)
  end

  def show
    merchant = Merchant.find(params[:id])
    render json: MerchantSerializer.new(merchant)
  end
end
