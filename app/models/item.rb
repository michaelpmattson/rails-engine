class Item < ApplicationRecord
  belongs_to :merchant
  has_many   :invoice_items, dependent: :destroy
  has_many   :invoices, through: :invoice_items

  def self.find_all_by_name(name)
    where("LOWER(name) LIKE ?", "%#{name.downcase}%")
      .order(Arel.sql('LOWER(name)'))
  end

  def self.find_all_by_price(price_params)
    find_by_min_price(price_params)
      .find_by_max_price(price_params)
      .order(Arel.sql('LOWER(name)'))
  end

  def self.sort_by_revenue(limit_num)
    joins(invoice_items: {invoice: :transactions})
      .merge(Transaction.successful)
      .select("items.*, SUM(invoice_items.unit_price * invoice_items.quantity) AS revenue")
      .group(:id)
      .order(revenue: :desc)
      .limit(limit_num)
  end

  private

  def self.find_by_min_price(price_params)
    where("unit_price >= ?", price_params[:min_price].to_f)
  end

  def self.find_by_max_price(price_params)
    return all if price_params[:max_price].nil?

    where("unit_price <= ?", price_params[:max_price].to_f)
  end
end
