require 'rails_helper'

describe 'Items API' do
  let!(:merchant1) { create(:merchant) }
  let!(:item1) { create(:item, merchant_id: merchant1.id) }
  let!(:item2) { create(:item, merchant_id: merchant1.id) }
  let!(:item3) { create(:item, merchant_id: merchant1.id) }

  let!(:merchant2) { create(:merchant) }
  let!(:item4) { create(:item, merchant_id: merchant2.id) }
  let!(:item5) { create(:item, merchant_id: merchant2.id) }
  let!(:item6) { create(:item, merchant_id: merchant2.id) }

  context 'GETs all items' do

    it 'can get all of the items' do
      get api_v1_items_path

      expect(response).to be_successful

      parsed = JSON.parse(response.body, symbolize_names: true)
      items = parsed[:data]

      expect(items.count).to eq(6)

      items.each do |item|
        expect(item).to have_key(:id)
        expect(item[:id]).to be_a(String)
        
        expect(item[:attributes]).to have_key(:name)
        expect(item[:attributes][:name]).to be_a(String)
        
        expect(item[:attributes]).to have_key(:description)
        expect(item[:attributes][:description]).to be_a(String)
        
        expect(item[:attributes]).to have_key(:unit_price)
        expect(item[:attributes][:unit_price]).to be_a(Float)
        
        expect(item[:attributes]).to have_key(:merchant_id)
        expect(item[:attributes][:merchant_id]).to be_a(Integer)
      end
    end
  end

  context 'GET one item' do
    it 'can get one item by id' do
      get api_v1_item_path(item1)

      expect(response).to be_successful

      parsed = JSON.parse(response.body, symbolize_names: true)
      item = parsed[:data]

      expect(item).to have_key(:id)
      expect(item[:id]).to be_a(String)
      expect(item[:id]).to eq(item1.id.to_s)
      
      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_a(String)
      
      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes][:description]).to be_a(String)
      
      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes][:unit_price]).to be_a(Float)
      
      expect(item[:attributes]).to have_key(:merchant_id)
      expect(item[:attributes][:merchant_id]).to be_a(Integer)
      expect(item[:attributes][:merchant_id]).to eq(merchant1.id)
    end
  end

  context 'CREATE an item' do
    it 'can create an item' do
      item_params = ({
        name: 'Watch',
        description: 'Time telling device',
        unit_price: 4000,
        merchant_id: merchant1.id
      })
      headers = {"CONTENT_TYPE" => "application/json"}
      post api_v1_items_path, headers: headers, params: JSON.generate(item: item_params)
      created_item = Item.last

      expect(created_item.name).to eq(item_params[:name])
      expect(created_item.description).to eq(item_params[:description])
      expect(created_item.unit_price).to eq(item_params[:unit_price])
      expect(created_item.merchant_id).to eq(item_params[:merchant_id])
    end
  end

  context 'UPDATE an Item' do
    it 'can update an item' do
      id = create(:item, merchant_id: merchant1.id).id
      previous_name = Item.last.name
      item_params = { name: 'Bike Boy' }
      headers = {"CONTENT_TYPE" => "application/json"}
    
      patch api_v1_item_path(id), headers: headers, params: JSON.generate({item: item_params})
      item = Item.find_by(id: id)

      expect(response).to be_successful
      expect(item.name).to_not eq(previous_name)
      expect(item.name).to eq('Bike Boy')
    end
  end

  context 'DESTROY an Item' do
    it 'can destroy an item' do
      delete_item = create(:item, merchant_id: merchant1.id)

      expect(Item.count).to eq(7)

      delete api_v1_item_path(delete_item.id)

      expect(response).to be_successful
      expect(Item.count).to eq(6)
      expect{Item.find(delete_item.id)}.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'GET the merchant data for an item' do
    it 'can get the merchant associated with an item' do
      get api_v1_item_merchant_index_path(item1)

      expect(response).to be_successful

      parsed = JSON.parse(response.body, symbolize_names: true)
      merchant = parsed[:data]

      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_a(String)
      expect(merchant[:id]).to eq(merchant1.id.to_s)
    end
  end

  context 'GET all items based on search' do
    it 'can return all items based on search by name' do
      Item.destroy_all
      skis = create(:item, name: 'alpine skis', unit_price: 100, merchant_id: merchant1.id)
      tie = create(:item, name: 'neckTIE', unit_price: 200, merchant_id: merchant1.id)
      skirt = create(:item, name: 'skirts', unit_price: 300, merchant_id: merchant1.id)

      get api_v1_items_find_all_path(name: 'sk')

      parsed = JSON.parse(response.body, symbolize_names: true)

      items = parsed[:data]

      expect(items.count).to eq(2)

      item_skis = items[0]
      item_skirts = items[1]

      expect(item_skis[:id]).to eq(skis.id.to_s)
      expect(item_skis[:attributes][:name]).to eq('alpine skis')
      expect(item_skis[:attributes][:description]).to eq(skis.description)
      expect(item_skis[:attributes][:unit_price]).to eq(skis.unit_price)
      expect(item_skis[:attributes][:merchant_id]).to eq(merchant1.id)

      expect(item_skirts[:id]).to eq(skirt.id.to_s)
      expect(item_skirts[:attributes][:name]).to eq('skirts')
      expect(item_skirts[:attributes][:description]).to eq(skirt.description)
      expect(item_skirts[:attributes][:unit_price]).to eq(skirt.unit_price)
      expect(item_skirts[:attributes][:merchant_id]).to eq(merchant1.id)
    end

    it 'can return all items based on search by minimum price' do
      Item.destroy_all

      skis = create(:item, name: 'alpine skis', unit_price: 100, merchant_id: merchant1.id)
      tie = create(:item, name: 'neckTIE', unit_price: 200, merchant_id: merchant1.id)
      skirt = create(:item, name: 'skirts', unit_price: 300, merchant_id: merchant1.id)
      get api_v1_items_find_all_path(min_price: 199)

      parsed = JSON.parse(response.body, symbolize_names: true)

      items = parsed[:data]

      expect(items.count).to eq(2)

      item_tie = items[0]
      item_skirts = items[1]

      expect(item_tie[:id]).to eq(tie.id.to_s)
      expect(item_tie[:attributes][:name]).to eq('neckTIE')
      expect(item_tie[:attributes][:description]).to eq(tie.description)
      expect(item_tie[:attributes][:unit_price]).to eq(tie.unit_price)
      expect(item_tie[:attributes][:merchant_id]).to eq(merchant1.id)

      expect(item_skirts[:id]).to eq(skirt.id.to_s)
      expect(item_skirts[:attributes][:name]).to eq('skirts')
      expect(item_skirts[:attributes][:description]).to eq(skirt.description)
      expect(item_skirts[:attributes][:unit_price]).to eq(skirt.unit_price)
      expect(item_skirts[:attributes][:merchant_id]).to eq(merchant1.id)
    end

    it 'can return all items based on search by maximum price' do
      Item.destroy_all

      skis = create(:item, name: 'alpine skis', unit_price: 100, merchant_id: merchant1.id)
      tie = create(:item, name: 'neckTIE', unit_price: 200, merchant_id: merchant1.id)
      skirt = create(:item, name: 'skirts', unit_price: 300, merchant_id: merchant1.id)

      get api_v1_items_find_all_path(max_price: 201)

      parsed = JSON.parse(response.body, symbolize_names: true)

      items = parsed[:data]

      expect(items.count).to eq(2)

      item_skis = items[0]
      item_tie = items[1]

      expect(item_skis[:id]).to eq(skis.id.to_s)
      expect(item_skis[:attributes][:name]).to eq('alpine skis')
      expect(item_skis[:attributes][:description]).to eq(skis.description)
      expect(item_skis[:attributes][:unit_price]).to eq(skis.unit_price)
      expect(item_skis[:attributes][:merchant_id]).to eq(merchant1.id)

      expect(item_tie[:id]).to eq(tie.id.to_s)
      expect(item_tie[:attributes][:name]).to eq('neckTIE')
      expect(item_tie[:attributes][:description]).to eq(tie.description)
      expect(item_tie[:attributes][:unit_price]).to eq(tie.unit_price)
      expect(item_tie[:attributes][:merchant_id]).to eq(merchant1.id)
    end
  end
end