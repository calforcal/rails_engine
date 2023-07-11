require 'rails_helper'

describe 'Merchants API' do
  
  context 'GETs all merchants' do
    it 'can get call merchants' do
      create_list(:merchant, 5)

      get api_v1_merchants_path

      expect(response).to be_successful

      parsed = JSON.parse(response.body, symbolize_names: true)
      merchants = parsed[:data]

      expect(merchants.count).to eq(5)

      merchants.each do |merchant|
        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_a(String)
        
        expect(merchant[:attributes]).to have_key(:name)
        expect(merchant[:attributes][:name]).to be_a(String)
      end
    end
  end

  context 'GET one merchant' do
    it 'can get one merchant by id' do
      id = create(:merchant).id

      get api_v1_merchant_path(id)

      expect(response).to be_successful

      parsed = JSON.parse(response.body, symbolize_names: true)
      merchant = parsed[:data]

      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_a(String)
      
      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a(String)
    end
  end

  context 'GET one merchants items' do
    let!(:merchant) { create(:merchant) }
    let!(:item1) { create(:item, merchant_id: merchant.id) }
    let!(:item2) { create(:item, merchant_id: merchant.id) }
    let!(:item3) { create(:item, merchant_id: merchant.id) }

    it 'can get ALL of one merchants items' do
      get api_v1_merchant_items_path(merchant)

      expect(response).to be_successful

      parsed = JSON.parse(response.body, symbolize_names: true)
      items = parsed[:data]

      expect(items).to have_key(:id)
      expect(items[:id]).to be_a(String)
      
      expect(items[:attributes]).to have_key(:name)
      expect(items[:attributes][:name]).to be_a(String)

      expect(items[:attributes]).to have_key(:description)
      expect(items[:attributes][:description]).to be_a(String)

      expect(items[:attributes]).to have_key(:unit_price)
      expect(items[:attributes][:unit_price]).to be_a(String)

      expect(items[:attributes]).to have_key(:merchant_id)
      expect(items[:attributes][:merchant_id]).to be_a(String)
      expect(items[:attributes][:merchant_id]).to eq(merchant.id)
    end
  end
end