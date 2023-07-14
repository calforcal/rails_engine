class Api::V1::MerchantsController < ApplicationController
  def index
    merchants = Merchant.all
    render json: MerchantSerializer.new(merchants)
  end

  def show
    render json: MerchantSerializer.new(Merchant.find(params[:id]))
  end

  def find_by_search
    found_merchant = Merchant.search_by_name(params[:name])
    
    if found_merchant.nil?
      render json: MerchantSerializer.new(Merchant.new)
    else
      render json: MerchantSerializer.new(Merchant.search_by_name(params[:name]))
    end
  end
end