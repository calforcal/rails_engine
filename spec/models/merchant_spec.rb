require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'class methods' do
    describe '#search_by_name' do
      let!(:merchant1) { create(:merchant, name: "Buzz") }
      let!(:merchant2) { create(:merchant, name: 'Michael') }
      it 'can find a merchant through partial search of its name' do
        expect(Merchant.all).to eq([merchant1, merchant2])
        expect(Merchant.search_by_name('Bu')).to eq(merchant1)
      end
    end
  end
end