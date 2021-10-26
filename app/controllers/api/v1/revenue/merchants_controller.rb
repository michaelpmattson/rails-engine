class Api::V1::Revenue::MerchantsController < ApplicationController
  def index
    if params[:quantity].nil?
      render json: { error: 'Sorry, quantity must exist' }, status: 400
    elsif !integer?(params[:quantity])
      render json: { error: 'Sorry, quantity must be integer' }, status: 400
    elsif params[:quantity].to_i < 1
      render json: { error: 'Sorry, quantity must be greater than zero' }, status: 400
    else
      revenues = Merchant.sort_by_revenue(params[:quantity])
      render json: MerchantNameRevenueSerializer.new(revenues)
    end
  end

  def show
    merchant = Merchant.find(params[:id])
    revenue  = merchant.total_revenue
    merchant_revenue = { id: merchant.id, revenue: revenue }
    render json: MerchantRevenueSerializer.format_total_revenue(merchant_revenue)

  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Sorry, that merchant does not exist' }, status: 404
  end

  private

  def integer?(param)
    param.to_i.to_s == param
  end
end
