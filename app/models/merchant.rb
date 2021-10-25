class Merchant < ApplicationRecord
  has_many :items

  def self.find_all_by_name(name)
    where("LOWER(name) LIKE ?", "%#{name.downcase}%")
      .order('LOWER(name)')
  end
end
