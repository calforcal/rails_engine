class Api::V1::ItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(Item.all)
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id]))
  end

  def create
    render json: ItemSerializer.new(Item.create!(item_params)), status: :created
  end

  def update
    @item = Item.find(params[:id])
    @item.update!(item_params)

    render json: ItemSerializer.new(@item)
  end

  def destroy
    render json: ItemSerializer.new(Item.destroy(params[:id]))
  end

  def find_by_search
    found_items = Item.find_all_items(params)

    if !found_items
      render json: { errors: 'Bad Request' }, status: 400
    elsif found_items.empty?
      array = [Item.new]
      render json: ItemSerializer.new(array)
    else
      render json: ItemSerializer.new(found_items)
    end
  end

  private
  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end