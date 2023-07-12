class Api::V1::MerchantsController < ApplicationController
  def index
    merchants = Merchant.all
    render json: MerchantSerializer.new(merchants)
  end

  def show
    render json: MerchantSerializer.new(Merchant.find(params[:id]))
  end

  def find_by_search
    render json: MerchantSerializer.new(Merchant.search_by_name(params[:name]))
  end
end