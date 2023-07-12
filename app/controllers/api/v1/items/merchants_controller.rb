class Api::V1::Items::MerchantsController < ApplicationController
  def index
    item = Item.find(params[:item_id])
    render json: {
      item: ItemSerializer.new(item),
      merchant: MerchantSerializer.new(Merchant.find(item.merchant_id))
  }
  end
end