class Item < ApplicationRecord
  belongs_to :merchant

  def self.search_by_name(search)
    if search.nil?
      nil
    else
      where("name ILIKE ?", "%" + search + "%").order(name: :asc)
    end
  end

  def self.search_by_min_price(price)
    where("unit_price >= ?", price).order(unit_price: :asc)
  end

  def self.search_by_max_price(price)
    where("unit_price <= ?", price).order(unit_price: :asc)
  end
end