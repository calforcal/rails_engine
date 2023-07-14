class Merchant < ApplicationRecord
  has_many :items

  def self.search_by_name(search)
    where("name ILIKE ?", "%" + search + "%").order(name: :asc).first
  end

  # def self.validate_merchant(id)
  #   find(id).any?
  # end
end