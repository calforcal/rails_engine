class Merchant < ApplicationRecord
  has_many :items
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items
  has_many :transactions, through: :invoices
  has_many :customers, through: :invoices

  def self.search_by_name(search)
    where("name ILIKE ?", "%" + search + "%").order(name: :asc).first
  end

  # def self.validate_merchant(id)
  #   find(id).any?
  # end
end