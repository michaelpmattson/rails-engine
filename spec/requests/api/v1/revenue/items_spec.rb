require 'rails_helper'

RSpec.describe 'revenue for items api' do
  describe 'items with most revenue' do
    before(:each) do
      @merchant_1 = create(:merchant)
      @m1_items   = create_list(:item, 20, merchant: @merchant_1)

      @m1_invoices    = create_list(:invoice, 15, merchant: @merchant_1)
      # 55.5
      @m1_inv_items_1 = create_list(:invoice_item, 5, invoice: @m1_invoices[0], item: @m1_items[0], quantity: 2, unit_price: 5.55)
      # 333.3
      @m1_inv_items_2 = create_list(:invoice_item, 6, invoice: @m1_invoices[1], item: @m1_items[1], quantity: 5,  unit_price: 11.11)
      @m1_inv_items_3 = create_list(:invoice_item, 5, invoice: @m1_invoices[-1], item: @m1_items[2], quantity: 15, unit_price: 22.22)

      @m1_transaction_1 = create(:transaction, invoice: @m1_invoices[0], result: 'success')
      @m1_transaction_2 = create(:transaction, invoice: @m1_invoices[1], result: 'success')
      @m1_transaction_3 = create(:transaction, invoice: @m1_invoices[-1], result: 'failed')


      @merchant_2 = create(:merchant)
      @m2_items   = create_list(:item, 20, merchant: @merchant_2)

      @m2_invoices    = create_list(:invoice, 15, merchant: @merchant_2)
      # 148.08
      @m2_inv_items_1 = create_list(:invoice_item, 6, invoice: @m2_invoices[0], item: @m2_items[0], quantity: 2, unit_price: 12.34)
      # 1419.5
      @m2_inv_items_2 = create_list(:invoice_item, 5, invoice: @m2_invoices[1], item: @m2_items[1], quantity: 5,  unit_price: 56.78)
      @m2_inv_items_3 = create_list(:invoice_item, 5, invoice: @m2_invoices[-1], item: @m2_items[2], quantity: 15, unit_price: 22.22)

      @m2_transaction_1 = create(:transaction, invoice: @m2_invoices[0], result: 'success')
      @m2_transaction_2 = create(:transaction, invoice: @m2_invoices[1], result: 'success')
      @m2_transaction_3 = create(:transaction, invoice: @m2_invoices[-1], result: 'failed')


      @merchant_3 = create(:merchant)
      @m3_items   = create_list(:item, 20, merchant: @merchant_3)

      @m3_invoices    = create_list(:invoice, 15, merchant: @merchant_3)
      # 166.5
      @m3_inv_items_1 = create_list(:invoice_item, 5, invoice: @m3_invoices[0], item: @m3_items[0], quantity: 10, unit_price: 3.33)
      # 27.75
      @m3_inv_items_2 = create_list(:invoice_item, 5, invoice: @m3_invoices[1], item: @m3_items[1], quantity: 5,  unit_price: 1.11)
      @m3_inv_items_3 = create_list(:invoice_item, 5, invoice: @m3_invoices[-1], item: @m3_items[2], quantity: 15, unit_price: 22.22)

      @m3_transaction_1 = create(:transaction, invoice: @m3_invoices[0], result: 'success')
      @m3_transaction_2 = create(:transaction, invoice: @m3_invoices[1], result: 'success')
      @m3_transaction_3 = create(:transaction, invoice: @m3_invoices[-1], result: 'failed')


      # extra items
      @m1_inv_items_4 = create_list(:invoice_item, 1, invoice: @m1_invoices[0], item: @m1_items[3], quantity: 4, unit_price: 1.00)
      @m1_inv_items_5 = create_list(:invoice_item, 1, invoice: @m1_invoices[0], item: @m1_items[4], quantity: 3,  unit_price: 1.10)
      @m1_inv_items_6 = create_list(:invoice_item, 1, invoice: @m1_invoices[0], item: @m1_items[5], quantity: 2, unit_price: 1.01)
      @m1_inv_items_7 = create_list(:invoice_item, 1, invoice: @m1_invoices[0], item: @m1_items[6], quantity: 1, unit_price: 1.02)
    end

    it 'returns items and total revenue in order of highest revenue' do
      get('/api/v1/revenue/items?quantity=3')

      expect(response).to be_successful

      revenues = JSON.parse(response.body, symbolize_names: true)
      # require "pry"; binding.pry
      expect(revenues).to have_key(:data)
      expect(revenues[:data]).to be_an(Array)

      revenues[:data].each do |item|
        expect(item).to have_key(:id)
        expect(item[:id]).to be_a(String)

        expect(item).to have_key(:type)
        expect(item[:type]).to eq('item_revenue')

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

        expect(item[:attributes]).to have_key(:revenue)
        expect(item[:attributes][:revenue]).to be_a(Float)
      end

      expect(revenues[:data].count).to      eq(3)
      expect(revenues[:data].first[:id]).to eq(@m2_items[1].id.to_s)
      expect(revenues[:data].last[:id]).to  eq(@m3_items[0].id.to_s)
    end

    it 'can limit the number of items returned' do
      get('/api/v1/revenue/items?quantity=2')

      expect(response).to be_successful

      revenues = JSON.parse(response.body, symbolize_names: true)

      expect(revenues[:data].count).to      eq(2)
      expect(revenues[:data].first[:id]).to eq(@m2_items[1].id.to_s)
      expect(revenues[:data].last[:id]).to  eq(@m1_items[1].id.to_s)
    end

    it 'defaults to 10 items when no quantity param is entered' do
      get('/api/v1/revenue/items')

      expect(response).to be_successful

      revenues = JSON.parse(response.body, symbolize_names: true)

      expect(revenues[:data].count).to eq(10)
    end

    it 'errors when quantity is 0 or lower' do
      get('/api/v1/revenue/items?quantity=0')

      expect(response.status).to be(400)
      revenues = JSON.parse(response.body, symbolize_names: true)
      expect(revenues[:error]).to eq('Sorry, quantity must be greater than zero')

      get('/api/v1/revenue/items?quantity=-1')

      expect(response.status).to be(400)
      revenues = JSON.parse(response.body, symbolize_names: true)
      expect(revenues[:error]).to eq('Sorry, quantity must be greater than zero')
    end

    it 'errors when quantity is not an integer' do
      get('/api/v1/revenue/items?quantity=potato')

      revenues = JSON.parse(response.body, symbolize_names: true)
      expect(revenues[:error]).to eq('Sorry, quantity must be integer')
      get('/api/v1/revenue/merchants?quantity=1.1')
    end
  end
end
