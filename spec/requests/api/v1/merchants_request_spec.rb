require 'rails_helper'

describe 'Merchants API' do

  let!(:merchant1) { create(:merchant, name: 'Bike Shop') }
  let!(:merchant2) { create(:merchant, name: 'Tacos') }
  let!(:merchant3) { create(:merchant, name: 'Truck Stop') }

  context 'GETs all merchants' do
    it 'can get call merchants' do

      get api_v1_merchants_path

      expect(response).to be_successful

      parsed = JSON.parse(response.body, symbolize_names: true)
      merchants = parsed[:data]

      expect(merchants.count).to eq(3)

      bike = merchants[0]
      taco = merchants[1]
      truck = merchants[2]

      merchants.each do |merchant|
        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_a(String)
        
        expect(merchant[:attributes]).to have_key(:name)
        expect(merchant[:attributes][:name]).to be_a(String)
      end

      expect(bike[:id]).to eq(merchant1.id.to_s)
      expect(bike[:attributes][:name]).to eq('Bike Shop')

      expect(taco[:id]).to eq(merchant2.id.to_s)
      expect(taco[:attributes][:name]).to eq('Tacos')

      expect(truck[:id]).to eq(merchant3.id.to_s)
      expect(truck[:attributes][:name]).to eq('Truck Stop')
    end
  end

  context 'GET one merchant' do
    it 'can get one merchant by id' do
      get api_v1_merchant_path(merchant1)

      expect(response).to be_successful

      parsed = JSON.parse(response.body, symbolize_names: true)
      merchant = parsed[:data]

      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_a(String)
      
      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a(String)

      expect(merchant[:id]).to eq(merchant1.id.to_s)
      expect(merchant[:attributes][:name]).to eq('Bike Shop')
    end
  end

  context 'GET one merchants items' do
    let!(:merchant) { create(:merchant) }
    let!(:item1) { create(:item, name: 'Bike', description: 'It rolls good', unit_price: 5000, merchant_id: merchant.id) }
    let!(:item2) { create(:item, name: 'Tire', description: 'Helps with rolling', unit_price: 100,  merchant_id: merchant.id) }

    it 'can get ALL of one merchants items' do
      get api_v1_merchant_items_path(merchant)

      expect(response).to be_successful

      parsed = JSON.parse(response.body, symbolize_names: true)
      items = parsed[:data]

      bike = items[0]
      tire = items[1]

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

      expect(bike[:attributes][:name]).to eq('Bike')
      expect(bike[:attributes][:description]).to eq('It rolls good')
      expect(bike[:attributes][:unit_price]).to eq(5000)
      expect(bike[:attributes][:merchant_id]).to eq(merchant.id)

      expect(tire[:attributes][:name]).to eq('Tire')
      expect(tire[:attributes][:description]).to eq('Helps with rolling')
      expect(tire[:attributes][:unit_price]).to eq(100)
      expect(tire[:attributes][:merchant_id]).to eq(merchant.id)
    end
  end

  context 'GET one merchant based on search' do
    let!(:find_merchant) { create(:merchant, name: "Buzz") }

    it 'can find one merchant based on searching name' do
      get api_v1_merchants_find_path(name: 'Bu')

      expect(response).to be_successful

      parsed = JSON.parse(response.body, symbolize_names: true)
      
      merchant = parsed[:data]

      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_a(String)
      expect(merchant[:id]).to eq(find_merchant.id.to_s)
      
      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a(String)
      expect(merchant[:attributes][:name]).to eq('Buzz')
    end
  end
end