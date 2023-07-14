require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'class methods' do
    describe '#search_by_name' do
      let!(:merchant1) { create(:merchant, name: "Buzz") }
      let!(:skis) { create(:item, name: 'alpine skis', unit_price: 100, merchant_id: merchant1.id) }
      let!(:tie) { create(:item, name: 'neckTIE', unit_price: 200, merchant_id: merchant1.id) }
      let!(:skirt) { create(:item, name: 'skirts', unit_price: 300, merchant_id: merchant1.id) }

      it 'can find all items through partial search of its name' do
        expect(Item.all).to eq([skis, tie, skirt])
        expect(Item.search_by_name('sK')).to eq([skis, skirt])
      end

      it 'can find all items based on a minimum price' do
        expect(Item.all).to eq([skis, tie, skirt])
        expect(Item.find_all_by_price(min_price: 199)).to eq([tie, skirt])
      end

      it 'can find all items based on a maximum price' do
        expect(Item.all).to eq([skis, tie, skirt])
        expect(Item.find_all_by_price(max_price: 201)).to eq([skis, tie])
      end
    end
  end
end