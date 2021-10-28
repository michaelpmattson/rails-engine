require 'rails_helper'

describe 'Items API' do
  describe 'index request' do
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
      get('/api/v1/items')

      expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)

      expect(items).to have_key(:data)
      expect(items[:data]).to be_an(Array)

      items[:data].each do |item|
        expect(item).to have_key(:id)
        expect(item[:id]).to be_a(String)

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

    it 'defaults to 20 items' do
      get('/api/v1/items')
      items = JSON.parse(response.body, symbolize_names: true)
      expect(items[:data].count).to eq(20)
    end

    it 'can take query params per_page and page' do
      get '/api/v1/items?per_page=50&page=2'

      items    = JSON.parse(response.body, symbolize_names: true)
      first_id = Item.first.id
      ar_items = Item.where('id > ?', first_id + 49 ).order(:id).limit(50)

      expect(items[:data].count).to eq(50)
      expect(items[:data].first[:id].to_i).to eq(ar_items.first.id)
      expect(items[:data].last[:id].to_i).to  eq(ar_items.last.id)
    end
  end

  describe 'show request' do
    before(:each) do
      @item = create(:item)
    end

    it 'can get an item by its id' do
      get("/api/v1/items/#{@item.id}")

      expect(response).to be_successful

      item = JSON.parse(response.body, symbolize_names: true)

      expect(item).to have_key(:data)
      expect(item[:data]).to be_a(Hash)

      expect(item[:data]).to have_key(:id)
      expect(item[:data][:id]).to be_an(String)
      expect(item[:data][:id].to_i).to eq(@item.id)

      expect(item[:data]).to have_key(:type)
      expect(item[:data][:type]).to be_a(String)

      expect(item[:data]).to have_key(:attributes)
      expect(item[:data][:attributes]).to be_a(Hash)

      expect(item[:data][:attributes]).to have_key(:name)
      expect(item[:data][:attributes][:name]).to be_a(String)
      expect(item[:data][:attributes][:name]).to eq(@item.name)

      expect(item[:data][:attributes]).to have_key(:description)
      expect(item[:data][:attributes][:description]).to be_a(String)
      expect(item[:data][:attributes][:description]).to eq(@item.description)

      expect(item[:data][:attributes]).to have_key(:unit_price)
      expect(item[:data][:attributes][:unit_price]).to be_a(Float)
      expect(item[:data][:attributes][:unit_price]).to eq(@item.unit_price)

      expect(item[:data][:attributes]).to have_key(:merchant_id)
      expect(item[:data][:attributes][:merchant_id]).to be_an(Integer)
      expect(item[:data][:attributes][:merchant_id]).to eq(@item.merchant_id)
    end
  end

  describe 'create request' do
    it 'can create a new item' do
      merchant    = create(:merchant)
      item_params = ({
        "name": "value1",
        "description": "value2",
        "unit_price": 100.99,
        "merchant_id": merchant.id
      })
      headers = {"CONTENT_TYPE" => "application/json"}

      post('/api/v1/items', headers: headers, params: JSON.generate(item: item_params))

      created_item = Item.last

      expect(response).to                   be_successful
      expect(created_item.name).to          eq(item_params[:name])
      expect(created_item.description).to   eq(item_params[:description])
      expect(created_item.unit_price).to    eq(item_params[:unit_price])
      expect(created_item.merchant_id).to   eq(item_params[:merchant_id])
    end
  end


  describe 'update request' do
    it 'can update an existing item' do
      id            = create(:item).id
      previous_name = Item.last.name
      item_params   = {
        "name": "value1",
      }
      headers = {"CONTENT_TYPE" => "application/json"}

      patch("/api/v1/items/#{id}", headers: headers, params: JSON.generate({item: item_params}))

      item = Item.find_by(id: id)

      expect(response).to      be_successful
      expect(item.name).to_not eq(previous_name)
      expect(item.name).to     eq("value1")
    end

    it '404 when item does not exist' do
      id            = create(:item).id
      previous_name = Item.last.name
      item_params   = {
        "name": "value1",
      }
      headers = {"CONTENT_TYPE" => "application/json"}

      patch("/api/v1/items/9999999999", headers: headers, params: JSON.generate({item: item_params}))

      expect(response.status).to be(404)

      r_body = JSON.parse(response.body, symbolize_names: true)
      expect(r_body[:error]).to eq("Couldn't find Item with 'id'=9999999999")
    end

    it 'throws an error when updated to merchant that does not exist' do
      id            = create(:item).id
      previous_name = Item.last.name
      item_params   = {
        "merchant_id": "999999999",
      }
      headers = {"CONTENT_TYPE" => "application/json"}

      patch("/api/v1/items/#{id}", headers: headers, params: JSON.generate({item: item_params}))

      expect(response.status).to be(404)

      r_body = JSON.parse(response.body, symbolize_names: true)
      expect(r_body[:error]).to eq("Couldn't find Merchant with 'id'=999999999")
    end
  end

  describe 'destroy request' do
    it 'can destroy an item' do
      item = create(:item)

      expect{ delete("/api/v1/items/#{item.id}") }.to change(Item, :count).by(-1)

      expect(response).to be_successful
      expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'relationship request' do
    before(:each) do
      @merchant_1 = create(:merchant)
      @m1_items   = create_list(:item, 20, merchant: @merchant_1)
      @merchant_2 = create(:merchant)
      @m2_items   = create_list(:item, 20, merchant: @merchant_2)
    end

    it 'can return the merchant associated with an item' do
      get("/api/v1/items/#{@m1_items.first.id}/merchant")

      expect(response).to be_successful

      merchant = JSON.parse(response.body, symbolize_names: true)
      expect(merchant).to have_key(:data)
      expect(merchant[:data]).to be_a(Hash)

      expect(merchant[:data]).to have_key(:id)
      expect(merchant[:data][:id]).to be_an(String)
      expect(merchant[:data][:id].to_i).to eq(@m1_items.first.merchant.id)

      expect(merchant[:data]).to have_key(:type)
      expect(merchant[:data][:type]).to be_a(String)

      expect(merchant[:data]).to have_key(:attributes)
      expect(merchant[:data][:attributes]).to be_a(Hash)

      expect(merchant[:data][:attributes]).to have_key(:name)
      expect(merchant[:data][:attributes][:name]).to be_a(String)
      expect(merchant[:data][:attributes][:name]).to eq(@m1_items.first.merchant.name)
    end

    it 'does not include other merchants items' do
      get("/api/v1/items/#{@m1_items.first.id}/merchant")
      merchant = JSON.parse(response.body, symbolize_names: true)
      expect(merchant[:data][:id]).to_not eq(@m2_items.first.merchant.id)
    end

    it 'throws a 404 for merchant not found' do
      get("/api/v1/items/osudfgas/merchant")

      expect(response.status).to be(404)

      items = JSON.parse(response.body, symbolize_names: true)
      expect(items[:error]).to eq("Couldn't find Item with 'id'=osudfgas")
    end
  end
end
