class Item < ApplicationRecord
  belongs_to :merchant

  def self.search_by_name(search)
    where("name ILIKE ?", "%" + search + "%")
  end

  def self.search_by_min_price(price)
    where("unit_price >= ?", price)
  end

  def self.search_by_max_price(price)
    where("unit_price <= ?", price)
  end
end