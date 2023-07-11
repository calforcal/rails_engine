require 'rails_helper'

describe 'Merchants API' do
  
  context 'GETs all merchants' do
    it 'can get call merchants' do
      create_list(:merchant, 5)

      get api_v1_merchants_path

      expect(response).to be_successful

      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants.count).to eq(5)

      merchants.each do |merchant|
        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_an(Integer)
        
        expect(merchant).to have_key(:name)
        expect(merchant[:name]).to be_a(String)
      end
    end
  end

  context 'GET one merchant' do
    it 'can get one merchant by id' do
      id = create(:merchant).id
      
      get api_v1_merchant(id)

      expect(response).to be_successful

      merchant = JSON.parse(response.body, symbolize_names: true)

      expect(merchant.count).to eq(1)


      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_an(Integer)
      
      expect(merchant).to have_key(:name)
      expect(merchant[:name]).to be_a(String)
    end
  end
end