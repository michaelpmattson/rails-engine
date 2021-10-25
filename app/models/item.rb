class Item < ApplicationRecord
  belongs_to :merchant

  def self.find_all_by_name(name)
    where("LOWER(name) LIKE ?", "%#{name.downcase}%")
      .order('LOWER(name)')
  end
end
