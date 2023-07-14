require 'rails_helper'

describe 'Items API' do
  let!(:merchant1) { create(:merchant, name: 'Bike Shop') }
  let!(:merchant2) { create(:merchant, name: 'Other Shop') }
  let!(:item1) { create(:item, name: 'Bike', description: 'It rolls good', unit_price: 100, merchant_id: merchant1.id) }
  let!(:item2) { create(:item, name: 'Tire', description: 'Helps with rolling', unit_price: 200,  merchant_id: merchant1.id) }
  let!(:item3) { create(:item, name: 'Bike Helmet', description: 'Keeps you safe', unit_price: 300,  merchant_id: merchant1.id) }

  describe 'Fetch All Items' do
    context 'happy paths' do
      it 'can get all of the items' do
        get api_v1_items_path

        expect(response).to be_successful

        parsed = JSON.parse(response.body, symbolize_names: true)

        items = parsed[:data]

        expect(items.count).to eq(3)

        bike = items[0]
        tire = items[1]
        helmet  = items[2]
        
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
        expect(bike[:attributes][:unit_price]).to eq(100)
        expect(bike[:attributes][:merchant_id]).to eq(merchant1.id)

        expect(tire[:attributes][:name]).to eq('Tire')
        expect(tire[:attributes][:description]).to eq('Helps with rolling')
        expect(tire[:attributes][:unit_price]).to eq(200)
        expect(tire[:attributes][:merchant_id]).to eq(merchant1.id)

        expect(helmet[:attributes][:name]).to eq('Bike Helmet')
        expect(helmet[:attributes][:description]).to eq('Keeps you safe')
        expect(helmet[:attributes][:unit_price]).to eq(300)
        expect(helmet[:attributes][:merchant_id]).to eq(merchant1.id)
      end
    end
  end

  describe 'Fetch One Item' do
    context 'happy paths' do
      it 'gets one item by id' do
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

        expect(item[:attributes][:name]).to eq('Bike')
        expect(item[:attributes][:description]).to eq('It rolls good')
        expect(item[:attributes][:unit_price]).to eq(100)
        expect(item[:attributes][:merchant_id]).to eq(merchant1.id)
      end
    end

    context 'sad paths' do
      it 'returns a 404 when an invalid id is passed' do
        get api_v1_item_path(123456789123456789)

        expect(response).to_not be_successful
        expect(response.status).to eq(404)
  
        data = JSON.parse(response.body, symbolize_names: true)
        
        expect(data[:errors]).to be_a(Array)
        expect(data[:errors].first[:status]).to eq('404')
        expect(data[:errors].first[:title]).to eq("Couldn't find Item with 'id'=123456789123456789")
      end
    end

    context 'edge case' do
      it 'returns a 404 when a string id is passed' do
        get api_v1_item_path('Bike')

        expect(response).to_not be_successful
        expect(response.status).to eq(404)
  
        data = JSON.parse(response.body, symbolize_names: true)
        
        expect(data[:errors]).to be_a(Array)
        expect(data[:errors].first[:status]).to eq('404')
        expect(data[:errors].first[:title]).to eq("Couldn't find Item with 'id'=Bike")
      end
    end
  end

  describe 'Create One Item' do
    context 'happy paths' do
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
  end

  describe 'Fetch and Update One Item' do
    context 'happy paths' do
      it 'can fetch and update one item with complete data' do
        id = create(:item, merchant_id: merchant1.id).id
        previous_name = Item.last.name
        previous_description = Item.last.description
        previous_unit_price = Item.last.unit_price
        previous_merchant_id = Item.last.merchant_id

        item_params = { name: 'Bike Person', description: 'This person loves bikes?', unit_price: 50.50, merchant_id: merchant2.id }
        headers = {"CONTENT_TYPE" => "application/json"}
      
        patch api_v1_item_path(id), headers: headers, params: JSON.generate({item: item_params})
        item = Item.find_by(id: id)

        expect(response).to be_successful
        expect(item.name).to_not eq(previous_name)
        expect(item.name).to eq('Bike Person')
        expect(item.description).to_not eq(previous_description)
        expect(item.description).to eq('This person loves bikes?')
        expect(item.unit_price).to_not eq(previous_unit_price)
        expect(item.unit_price).to eq(50.50)
        expect(item.merchant_id).to_not eq(previous_merchant_id)
        expect(item.merchant_id).to eq(merchant2.id)
      end

      it 'can fetch and update one item with complete data' do
        id = create(:item, merchant_id: merchant1.id).id
        previous_name = Item.last.name

        item_params = { name: 'Bike Person' }
        headers = {"CONTENT_TYPE" => "application/json"}
      
        patch api_v1_item_path(id), headers: headers, params: JSON.generate({item: item_params})
        item = Item.find_by(id: id)

        expect(response).to be_successful
        expect(item.name).to_not eq(previous_name)
        expect(item.name).to eq('Bike Person')
      end
    end

    context 'sad paths' do
      it 'returns a 404 when an invalid id is passed' do
        patch api_v1_item_path(123456789123456789)

        expect(response).to_not be_successful
        expect(response.status).to eq(404)
  
        data = JSON.parse(response.body, symbolize_names: true)
        
        expect(data[:errors]).to be_a(Array)
        expect(data[:errors].first[:status]).to eq('404')
        expect(data[:errors].first[:title]).to eq("Couldn't find Item with 'id'=123456789123456789")
      end
    end

    context 'edge case' do
      it 'returns a 404 when a string id is passed' do
        patch api_v1_item_path('Bike')

        expect(response).to_not be_successful
        expect(response.status).to eq(404)
  
        data = JSON.parse(response.body, symbolize_names: true)
        
        expect(data[:errors]).to be_a(Array)
        expect(data[:errors].first[:status]).to eq('404')
        expect(data[:errors].first[:title]).to eq("Couldn't find Item with 'id'=Bike")
      end

      it 'returns a 404 when a bad merchant_id is passed' do
        id = create(:item, merchant_id: merchant1.id).id
        
        item_params = {  merchant_id: 123456789123456789 }
        headers = {"CONTENT_TYPE" => "application/json"}
      
        patch api_v1_item_path(id), headers: headers, params: JSON.generate({item: item_params})

        expect(response).to_not be_successful
        expect(response.status).to eq(404)
  
        data = JSON.parse(response.body, symbolize_names: true)
        
        expect(data[:errors]).to be_a(Array)
        expect(data[:errors].first[:status]).to eq('404')
        expect(data[:errors].first[:title]).to eq("Validation failed: Merchant must exist")
      end
    end
  end

  describe 'Fetch and Destroy an Item' do
    context 'happy paths' do
      it 'can destroy an item' do
        delete_item = create(:item, merchant_id: merchant1.id)

        expect(Item.count).to eq(4)

        delete api_v1_item_path(delete_item.id)

        expect(response).to be_successful
        expect(Item.count).to eq(3)
        expect{Item.find(delete_item.id)}.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'Fetch Merchant data for an Item' do
    context 'happy paths' do
      it 'can get the merchant associated with an item' do
        get api_v1_item_merchant_index_path(item1)

        expect(response).to be_successful

        parsed = JSON.parse(response.body, symbolize_names: true)
        merchant = parsed[:data]

        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_a(String)

        expect(merchant[:id]).to eq(merchant1.id.to_s)
        expect(merchant[:attributes][:name]).to eq('Bike Shop')
      end
    end

    context 'sad paths' do
      it 'returns a 404 when an invalid id is passed' do
        get api_v1_item_merchant_index_path(123456789123456789)

        expect(response).to_not be_successful
        expect(response.status).to eq(404)
  
        data = JSON.parse(response.body, symbolize_names: true)
        
        expect(data[:errors]).to be_a(Array)
        expect(data[:errors].first[:status]).to eq('404')
        expect(data[:errors].first[:title]).to eq("Couldn't find Item with 'id'=123456789123456789")
      end
    end

    context 'edge cases' do
      it 'returns a 404 when an string id is passed' do
        get api_v1_item_merchant_index_path('A100')

        expect(response).to_not be_successful
        expect(response.status).to eq(404)
  
        data = JSON.parse(response.body, symbolize_names: true)
        
        expect(data[:errors]).to be_a(Array)
        expect(data[:errors].first[:status]).to eq('404')
        expect(data[:errors].first[:title]).to eq("Couldn't find Item with 'id'=A100")
      end
    end
  end

  describe 'Fetch all Items found based on Name Search' do
    context 'happy paths' do
      it 'can return all items based on search by name' do
        get api_v1_items_find_all_path(name: 'bik')

        parsed = JSON.parse(response.body, symbolize_names: true)

        items = parsed[:data]

        expect(items.count).to eq(2)

        item_bike = items[0]
        item_helmet = items[1]

        expect(item_bike[:id]).to eq(item1.id.to_s)
        expect(item_bike[:attributes][:name]).to eq('Bike')
        expect(item_bike[:attributes][:description]).to eq(item1.description)
        expect(item_bike[:attributes][:unit_price]).to eq(item1.unit_price)
        expect(item_bike[:attributes][:merchant_id]).to eq(merchant1.id)

        expect(item_helmet[:id]).to eq(item3.id.to_s)
        expect(item_helmet[:attributes][:name]).to eq('Bike Helmet')
        expect(item_helmet[:attributes][:description]).to eq(item3.description)
        expect(item_helmet[:attributes][:unit_price]).to eq(item3.unit_price)
        expect(item_helmet[:attributes][:merchant_id]).to eq(merchant1.id)
      end
    end

    context 'sad paths' do
      it 'No fragment matches' do
        get api_v1_items_find_all_path(name: 'ZZ')

        expect(response).to be_successful

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(parsed[:data][:type]).to eq('item')
      end
    end
  end

  describe 'Fetch all Items based on Min Price Search' do
    context 'happy paths' do
      it 'can return all items based on search by min_price' do
        get api_v1_items_find_all_path(min_price: 199)

        parsed = JSON.parse(response.body, symbolize_names: true)

        items = parsed[:data]

        expect(items.count).to eq(2)

        item_tire = items[0]
        item_helmet = items[1]

        expect(item_tire[:id]).to eq(item2.id.to_s)
        expect(item_tire[:attributes][:name]).to eq('Tire')
        expect(item_tire[:attributes][:description]).to eq(item2.description)
        expect(item_tire[:attributes][:unit_price]).to eq(item2.unit_price)
        expect(item_tire[:attributes][:merchant_id]).to eq(merchant1.id)

        expect(item_helmet[:id]).to eq(item3.id.to_s)
        expect(item_helmet[:attributes][:name]).to eq('Bike Helmet')
        expect(item_helmet[:attributes][:description]).to eq(item3.description)
        expect(item_helmet[:attributes][:unit_price]).to eq(item3.unit_price)
        expect(item_helmet[:attributes][:merchant_id]).to eq(merchant1.id)
      end

      it 'can return all items based on search by max_price' do
        get api_v1_items_find_all_path(max_price: 201)

        parsed = JSON.parse(response.body, symbolize_names: true)

        items = parsed[:data]

        expect(items.count).to eq(2)

        item_bike = items[0]
        item_tire = items[1]

        expect(item_bike[:id]).to eq(item1.id.to_s)
        expect(item_bike[:attributes][:name]).to eq('Bike')
        expect(item_bike[:attributes][:description]).to eq(item1.description)
        expect(item_bike[:attributes][:unit_price]).to eq(item1.unit_price)
        expect(item_bike[:attributes][:merchant_id]).to eq(merchant1.id)

        expect(item_tire[:id]).to eq(item2.id.to_s)
        expect(item_tire[:attributes][:name]).to eq('Tire')
        expect(item_tire[:attributes][:description]).to eq(item2.description)
        expect(item_tire[:attributes][:unit_price]).to eq(item2.unit_price)
        expect(item_tire[:attributes][:merchant_id]).to eq(merchant1.id)
      end
    end
  end
end