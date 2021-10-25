class Api::V1::Merchants::FindController < ApplicationController
  def index
    merchants = Merchant.find_all_by_name(params[:name])
    render json: MerchantSerializer.new(merchants)
  end

  def show
    merchant = Merchant.find_by_name(params[:name])
    if merchant.nil?
      render json: { data: {} }
    else
      render json: MerchantSerializer.new(merchant)
    end
  end
end
