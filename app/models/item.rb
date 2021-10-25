class Item < ApplicationRecord
  belongs_to :merchant

  def self.find_all_by_name(name)
    where("LOWER(name) LIKE ?", "%#{name.downcase}%")
      .order(Arel.sql('LOWER(name)'))
  end

  def self.find_all_by_price(price_params)
    min_price = price_params[:min_price]
    max_price = price_params[:max_price]
    if min_price
      wip = where("unit_price >= ?", min_price.to_f)
      .order(Arel.sql('LOWER(name)'))
      require "pry"; binding.pry
    elsif max_price
      wip = where("unit_price <= ?", max_price.to_f)
      .order(Arel.sql('LOWER(name)'))
    end
    # require "pry"; binding.pry
  end
end
