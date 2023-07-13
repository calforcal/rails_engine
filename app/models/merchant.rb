class Merchant < ApplicationRecord
  has_many :items

  def self.search_by_name(search)
    where("name ILIKE ?", "%" + search + "%").first
  end
end