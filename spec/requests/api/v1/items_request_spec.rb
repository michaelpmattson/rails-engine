require 'rails_helper'

describe 'Items API' do
  before(:each) do
    merchant_1 = create(:merchant)
    merchant_2 = create(:merchant)
    merchant_3 = create(:merchant)
    merchant_4 = create(:merchant)
    merchant_5 = create(:merchant)
    create_list(:item, 20, merchant: merchant_1)
    create_list(:item, 20, merchant: merchant_2)
    create_list(:item, 20, merchant: merchant_3)
    create_list(:item, 20, merchant: merchant_4)
    create_list(:item, 20, merchant: merchant_5)
  end

  it 'sends a list of items' do
    get '/api/v1/items'

    expect(response).to be_successful

    items = JSON.parse(response.body, symbolize_names: true)

    expect(items).to have_key(:data)
    expect(items[:data]).to be_an(Array)
    expect(items[:data].count).to eq(100)

    items[:data].each do |item|
      expect(item).to have_key(:id)

      expect(item).to have_key(:type)
      expect(item[:type]).to eq('item')

      expect(item).to have_key(:attributes)
      expect(item[:attributes]).to be_a(Hash)

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_a(String)

      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes][:description]).to be_a(String)

      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes][:unit_price]).to be_a(Float)

      expect(item[:attributes]).to have_key(:merchant_id)
      expect(item[:attributes][:merchant_id]).to be_an(Integer)
    end
  end
end
