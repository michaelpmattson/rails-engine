class Api::V1::MerchantsController < ApplicationController
  def index
    merchants = Merchant.limit(merchant_limit).offset(merchant_offset)
    render json: MerchantSerializer.new(merchants)
  end

  def show
    merchant = Merchant.find(params[:id])
    render json: MerchantSerializer.new(merchant)
  end

  private

  def merchant_limit
    params.fetch(:per_page, 20).to_i
  end

  def merchant_offset
    page = params.fetch(:page, 1).to_i
    page = 1 if page < 1
    (page - 1) * merchant_limit
  end
end
