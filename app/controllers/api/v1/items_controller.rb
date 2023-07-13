class Api::V1::ItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(Item.all)
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id]))
  end

  def create
    render json: ItemSerializer.new(Item.create(item_params)), status: :created
  end

  def update
    render json: ItemSerializer.new(Item.update(params[:id], item_params))
  end

  def destroy
    render json: ItemSerializer.new(Item.destroy(params[:id]))
  end

  def find_by_search
    if params.has_key?(:name)
      render json: ItemSerializer.new(Item.search_by_name(params[:name]))
    elsif params.has_key?(:min_price)
      render json: ItemSerializer.new(Item.search_by_min_price(params[:min_price]))
    elsif params.has_key?(:max_price)
      render json: ItemSerializer.new(Item.search_by_max_price(params[:max_price]))
    end
  end

  private
  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end