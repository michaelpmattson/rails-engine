require 'rails_helper'

describe 'Items API' do
  describe 'index request' do
    before(:each) do
      # create_list(:merchant, 100)
    end

    it 'sends a list of merchants' do
      create_list(:merchant, 100)

      get '/api/v1/merchants'

      expect(response).to be_successful

      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants).to have_key(:data)
      expect(merchants[:data]).to be_an(Array)

      merchants[:data].each do |merchant|
        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_a(String)

        expect(merchant).to have_key(:type)
        expect(merchant[:type]).to eq('merchant')

        expect(merchant).to have_key(:attributes)
        expect(merchant[:attributes]).to be_a(Hash)

        expect(merchant[:attributes]).to have_key(:name)
        expect(merchant[:attributes][:name]).to be_a(String)
      end
    end

    it 'defaults to 20 merchants' do
      create_list(:merchant, 100)

      get '/api/v1/merchants'
      merchants = JSON.parse(response.body, symbolize_names: true)
      expect(merchants[:data].count).to eq(20)
    end

    it 'can take query params per_page and page' do
      create_list(:merchant, 100)

      get '/api/v1/merchants?per_page=50&page=2'

      merchants    = JSON.parse(response.body, symbolize_names: true)
      first_id     = Merchant.order(:id).first.id
      ar_merchants = Merchant.where('id > ?', first_id + 49 )
      .order(:id)
      .limit(50)

      expect(merchants[:data].count).to eq(50)
      expect(merchants[:data].first[:id].to_i).to eq(ar_merchants.first.id)
      expect(merchants[:data].last[:id].to_i).to  eq(ar_merchants.last.id)
    end

    it 'returns page 1 if input page is less than 1' do
      create_list(:merchant, 100)

      get '/api/v1/merchants?page=0'
      merchants = JSON.parse(response.body, symbolize_names: true)
      expect(merchants[:data].count).to eq(20)
      ar_merchants = Merchant.order(:id)

      expect(merchants[:data].first[:id].to_i).to eq(ar_merchants.first.id)
    end
  end

  describe 'show request' do
    before(:each) do
      @merchant = create(:merchant)
    end

    it 'can get an merchant by its id' do
      get "/api/v1/merchants/#{@merchant.id}"

      expect(response).to be_successful

      merchant = JSON.parse(response.body, symbolize_names: true)

      expect(merchant).to have_key(:data)
      expect(merchant[:data]).to be_a(Hash)

      expect(merchant[:data]).to have_key(:id)
      expect(merchant[:data][:id]).to be_an(String)
      expect(merchant[:data][:id].to_i).to eq(@merchant.id)

      expect(merchant[:data]).to have_key(:type)
      expect(merchant[:data][:type]).to be_a(String)

      expect(merchant[:data]).to have_key(:attributes)
      expect(merchant[:data][:attributes]).to be_a(Hash)

      expect(merchant[:data][:attributes]).to have_key(:name)
      expect(merchant[:data][:attributes][:name]).to be_a(String)
      expect(merchant[:data][:attributes][:name]).to eq(@merchant.name)
    end
  end

  # describe 'create request' do
  #
  # end
  # describe 'update request' do
  #
  # end
  # describe 'destroy request' do
  #
  # end
  # describe 'relationship request' do
  #
  # end
end
