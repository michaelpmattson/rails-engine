class Api::V1::Revenue::MerchantsController < ApplicationController
  def index
    
  end

  def show
    merchant = Merchant.find(params[:id])
    revenue  = merchant.total_revenue
    merchant_revenue = { id: merchant.id, revenue: revenue }
    render json: MerchantRevenueSerializer.format_total_revenue(merchant_revenue)

  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Sorry, that merchant does not exist' }, status: 404
  end
end
