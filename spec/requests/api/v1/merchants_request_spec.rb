require 'rails_helper'

describe 'Merchants API' do
  let!(:merchant1) { create(:merchant, name: 'Bike Shop') }
  let!(:merchant2) { create(:merchant, name: 'Tacos') }
  let!(:merchant3) { create(:merchant, name: 'Truck Stop') }

  let!(:item1) { create(:item, name: 'Bike', description: 'It rolls good', unit_price: 5000, merchant_id: merchant1.id) }
  let!(:item2) { create(:item, name: 'Tire', description: 'Helps with rolling', unit_price: 100,  merchant_id: merchant1.id) }

  describe 'Fetch All Merchants' do
    context 'happy paths' do
      it 'can get all merchants' do

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
  end

  
  describe 'Fetch One Merchant' do
    context 'happy paths' do
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

    context 'sad paths' do
      it 'a bad merchant ID returns a 404 error' do
        get api_v1_merchant_path(123456789123456789)

        expect(response).to_not be_successful
        expect(response.status).to eq(404)

        data = JSON.parse(response.body, symbolize_names: true)
        
        expect(data[:errors]).to be_a(Array)
        expect(data[:errors].first[:status]).to eq('404')
        expect(data[:errors].first[:title]).to eq("Couldn't find Merchant with 'id'=123456789123456789")
      end
    end
  end

  describe 'Fetch a Merchants Items' do
    context 'happy paths' do
      it 'can get ALL of One Merchants Items' do
        get api_v1_merchant_items_path(merchant1)

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
        expect(bike[:attributes][:merchant_id]).to eq(merchant1.id)

        expect(tire[:attributes][:name]).to eq('Tire')
        expect(tire[:attributes][:description]).to eq('Helps with rolling')
        expect(tire[:attributes][:unit_price]).to eq(100)
        expect(tire[:attributes][:merchant_id]).to eq(merchant1.id)
      end
    end

    context 'sad paths' do
      it 'a bad merchant ID returns a 404 error' do
        get api_v1_merchant_items_path(123456789123456789)

        expect(response).to_not be_successful
        expect(response.status).to eq(404)

        data = JSON.parse(response.body, symbolize_names: true)
        
        expect(data[:errors]).to be_a(Array)
        expect(data[:errors].first[:status]).to eq('404')
        expect(data[:errors].first[:title]).to eq("Couldn't find Merchant with 'id'=123456789123456789")
      end
    end
  end    
  
  describe 'Fetch One Merchant based on search' do
    let!(:find_merchant) { create(:merchant, name: 'Tack Store') }
    context 'happy paths' do
      it 'can find one merchant based on searching name' do
        get api_v1_merchants_find_path(name: 'tA')

        expect(response).to be_successful

        parsed = JSON.parse(response.body, symbolize_names: true)
        
        merchant = parsed[:data]

        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_a(String)
        
        expect(merchant[:attributes]).to have_key(:name)
        expect(merchant[:attributes][:name]).to be_a(String)

        expect(merchant[:id]).to eq(find_merchant.id.to_s)
        expect(merchant[:attributes][:name]).to eq('Tack Store')
      end
    end

    context 'sad paths' do
      it 'No fragment matches' do
        get api_v1_merchants_find_path(name: 'ZZ')

        expect(response).to be_successful

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(parsed[:data][:type]).to eq('merchant')
      end
    end
  end
end