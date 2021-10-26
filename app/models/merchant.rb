class Merchant < ApplicationRecord
  has_many :items,    dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :transactions, through: :invoices

  def self.find_all_by_name(name)
    where("LOWER(name) LIKE ?", "%#{name.downcase}%")
      .order(Arel.sql('LOWER(name)'))
  end

  def self.find_by_name(name)
    find_all_by_name(name)
      .limit(1)
      .first
  end

  def total_revenue
    InvoiceItem.joins(invoice: :transactions)
               .where(invoices: {merchant_id: id}, transactions: {result: 'success'})
               .sum("quantity * unit_price")
  end
end
