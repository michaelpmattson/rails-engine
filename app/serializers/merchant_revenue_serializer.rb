class MerchantRevenueSerializer
  def self.format_total_revenue(params)
    {
      data: {
        id: params[:id].to_s,
        type: "merchant_revenue",
        attributes: { revenue: params[:revenue] }
      }
    }
  end
end
