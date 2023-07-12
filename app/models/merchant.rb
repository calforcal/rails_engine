class Merchant < ApplicationRecord
  has_many :items

  def self.search_by_name(search)
    where("name LIKE ?", search + "%").first
  end
end