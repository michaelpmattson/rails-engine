class Merchant < ApplicationRecord
  has_many :items,    dependent: :destroy
  has_many :invoices, dependent: :destroy

  def self.find_all_by_name(name)
    where("LOWER(name) LIKE ?", "%#{name.downcase}%")
      .order(Arel.sql('LOWER(name)'))
  end

  def self.find_by_name(name)
    find_all_by_name(name)
      .limit(1)
      .first
  end
end
