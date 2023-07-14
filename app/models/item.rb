class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items
  has_many :transactions, through: :invoices
  validates_presence_of :name, :description, :unit_price


  def self.find_all_items(params)
    if params[:name] && params[:min_price].nil? && params[:max_price].nil?
      Item.search_by_name(params[:name])
    elsif params[:name].nil? && (params[:min_price] || params[:max_price])
      Item.find_all_by_price(params)
    else
      false
    end
  end

  def self.find_all_by_price(params)
    min_price = params[:min_price].present? ? params[:min_price] : 0
    max_price = params[:max_price].present? ? params[:max_price] : 999_999

    Item.where("unit_price >= #{min_price} AND unit_price <= #{max_price}").order(unit_price: :asc)
  end

  def self.search_by_name(search)
    if search.nil?
      nil
    else
      where("name ILIKE ?", "%" + search + "%").order(name: :asc)
    end
  end
end