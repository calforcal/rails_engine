require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'class methods' do
    let!(:merchant1) { create(:merchant, name: "Buzz") }
    let!(:merchant2) { create(:merchant, name: 'Michael') }

    describe '#search_by_name' do
      it 'can find a merchant through partial search of its name' do
        expect(Merchant.all).to eq([merchant1, merchant2])
        expect(Merchant.search_by_name('Bu')).to eq(merchant1)
      end
    end

    # describe '#validate_merchant' do
    #   it 'returns true when merchant id exists' do
    #     expect(Merchant.validate_merchant(merchant1.id)).to be(true)
    #   end

    #   it 'returns false when merchant id doesnt exist' do
    #     expect(Merchant.validate_merchant('A100')).to eq(false)
    #   end
    # end
  end
end