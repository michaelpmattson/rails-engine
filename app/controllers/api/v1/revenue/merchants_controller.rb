class Api::V1::Revenue::MerchantsController < ApplicationController
  def show
    merchant = Merchant.find(params[:id])
    revenue  = merchant.total_revenue
    merchant_revenue = { id: merchant.id, revenue: revenue }
    require "pry"; binding.pry
    render json: MerchantRevenueSerializer.new(merchant_revenue)
  end
end
