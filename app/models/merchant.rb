class Merchant < ApplicationRecord
  has_many :items,    dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :transactions, through: :invoices
  has_many :invoice_items, through: :invoices

  def self.find_all_by_name(name)
    where("LOWER(name) LIKE ?", "%#{name.downcase}%")
      .order(Arel.sql('LOWER(name)'))
  end

  def self.find_by_name(name)
    find_all_by_name(name)
      .limit(1)
      .first
  end

  def self.sort_by_items_sold(limit_num)
    wip = joins(invoice_items: {invoice: :transactions})
      .merge(Transaction.successful)
      .select("merchants.*, SUM(invoice_items.quantity) AS items_sold")
      .group(:id)
      .order(items_sold: :desc)
      .limit(limit_num)
  end

  def self.sort_by_revenue(limit_num)
    joins(invoice_items: {invoice: :transactions})
      .merge(Transaction.successful)
      .select("merchants.*, SUM(invoice_items.unit_price * invoice_items.quantity) AS revenue")
      .group(:id)
      .order(revenue: :desc)
      .limit(limit_num)
  end

  def total_revenue
    InvoiceItem.joins(invoice: :transactions)
               .where(invoices: {merchant_id: id}, transactions: {result: 'success'})
               .sum("quantity * unit_price")
  end
end
