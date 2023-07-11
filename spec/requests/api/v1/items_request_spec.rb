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
end