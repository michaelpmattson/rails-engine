require 'rails_helper'

RSpec.describe 'most items api' do
  describe 'merchants with most items sold' do
    before(:each) do
      # Merchant 1, total items 35
      @merchant_1 = create(:merchant)
      @m1_items   = create_list(:item, 20, merchant: @merchant_1)

      @m1_invoices    = create_list(:invoice, 15, merchant: @merchant_1)
      @m1_inv_items_1 = create_list(:invoice_item, 5, invoice: @m1_invoices[0], item: @m1_items[0], quantity: 2, unit_price: 5.55)
      @m1_inv_items_2 = create_list(:invoice_item, 5, invoice: @m1_invoices[1], item: @m1_items[1], quantity: 5,  unit_price: 11.11)
      @m1_inv_items_3 = create_list(:invoice_item, 5, invoice: @m1_invoices[-1], item: @m1_items[2], quantity: 15, unit_price: 22.22)

      @m1_transaction_1 = create(:transaction, invoice: @m1_invoices[0], result: 'success')
      @m1_transaction_2 = create(:transaction, invoice: @m1_invoices[1], result: 'success')
      @m1_transaction_3 = create(:transaction, invoice: @m1_invoices[-1], result: 'failed')

      # Merchant 1, total items 50
      @merchant_2 = create(:merchant)
      @m2_items   = create_list(:item, 20, merchant: @merchant_2)

      @m2_invoices    = create_list(:invoice, 15, merchant: @merchant_2)
      @m2_inv_items_1 = create_list(:invoice_item, 5, invoice: @m2_invoices[0], item: @m2_items[0], quantity: 5, unit_price: 12.34)
      @m2_inv_items_2 = create_list(:invoice_item, 5, invoice: @m2_invoices[1], item: @m2_items[1], quantity: 5,  unit_price: 56.78)
      @m2_inv_items_3 = create_list(:invoice_item, 5, invoice: @m2_invoices[-1], item: @m2_items[2], quantity: 15, unit_price: 22.22)

      @m2_transaction_1 = create(:transaction, invoice: @m2_invoices[0], result: 'success')
      @m2_transaction_2 = create(:transaction, invoice: @m2_invoices[1], result: 'success')
      @m2_transaction_3 = create(:transaction, invoice: @m2_invoices[-1], result: 'failed')

      # Merchant 1, total items 60
      @merchant_3 = create(:merchant)
      @m3_items   = create_list(:item, 20, merchant: @merchant_3)

      @m3_invoices    = create_list(:invoice, 15, merchant: @merchant_3)
      @m3_inv_items_1 = create_list(:invoice_item, 5, invoice: @m3_invoices[0], item: @m3_items[0], quantity: 2, unit_price: 3.33)
      @m3_inv_items_2 = create_list(:invoice_item, 5, invoice: @m3_invoices[1], item: @m3_items[1], quantity: 10,  unit_price: 1.11)
      @m3_inv_items_3 = create_list(:invoice_item, 5, invoice: @m3_invoices[-1], item: @m3_items[2], quantity: 15, unit_price: 22.22)

      @m3_transaction_1 = create(:transaction, invoice: @m3_invoices[0], result: 'success')
      @m3_transaction_2 = create(:transaction, invoice: @m3_invoices[1], result: 'success')
      @m3_transaction_3 = create(:transaction, invoice: @m3_invoices[-1], result: 'failed')

      @merchant_4 = create(:merchant)
      @m3_invoices    = create_list(:invoice, 1, merchant: @merchant_3)
      @m3_inv_items_1 = create_list(:invoice_item, 1, invoice: @m3_invoices[0], item: @m3_items[0], quantity: 1, unit_price: 3.33)
      @m3_transaction_1 = create(:transaction, invoice: @m3_invoices[0], result: 'success')

      @merchant_5 = create(:merchant)
    end

    it 'returns merchants and total revenue in order of highest revenue' do
      get('/api/v1/merchants/most_items?quantity=3')

      expect(response).to be_successful

      items_sold = JSON.parse(response.body, symbolize_names: true)

      expect(items_sold).to have_key(:data)
      expect(items_sold[:data]).to be_an(Array)

      items_sold[:data].each do |merchant|
        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_a(String)

        expect(merchant).to have_key(:type)
        expect(merchant[:type]).to eq('items_sold')

        expect(merchant).to have_key(:attributes)
        expect(merchant[:attributes]).to be_a(Hash)

        expect(merchant[:attributes]).to have_key(:name)
        expect(merchant[:attributes][:name]).to be_a(String)

        expect(merchant[:attributes]).to have_key(:count)
        expect(merchant[:attributes][:count]).to be_an(Integer)
      end

      expect(items_sold[:data].count).to      eq(3)
      expect(items_sold[:data].first[:id]).to eq(@merchant_3.id.to_s)
      expect(items_sold[:data].last[:id]).to  eq(@merchant_1.id.to_s)
    end

    it 'can limit the number of merchants returned' do
      get('/api/v1/merchants/most_items?quantity=2')

      expect(response).to be_successful

      revenues = JSON.parse(response.body, symbolize_names: true)

      expect(revenues[:data].count).to      eq(2)
      expect(revenues[:data].first[:id]).to eq(@merchant_3.id.to_s)
      expect(revenues[:data].last[:id]).to  eq(@merchant_2.id.to_s)
    end

    it 'dafaults to 5 when no quantity param is entered' do
      get('/api/v1/merchants/most_items')

      expect(response.status).to be(400)
      revenues = JSON.parse(response.body, symbolize_names: true)
      expect(revenues[:error]).to eq('Sorry, quantity must exist')
    end

    it 'errors when quantity is 0 or lower' do
      get('/api/v1/merchants/most_items?quantity=0')

      expect(response.status).to be(400)
      revenues = JSON.parse(response.body, symbolize_names: true)
      expect(revenues[:error]).to eq('Sorry, quantity must be greater than zero')

      get('/api/v1/merchants/most_items?quantity=-1')

      expect(response.status).to be(400)
      revenues = JSON.parse(response.body, symbolize_names: true)
      expect(revenues[:error]).to eq('Sorry, quantity must be greater than zero')
    end

    it 'errors when quantity is not an integer' do
      get('/api/v1/merchants/most_items?quantity=potato')

      revenues = JSON.parse(response.body, symbolize_names: true)
      expect(revenues[:error]).to eq('Sorry, quantity must be integer')
      get('/api/v1/revenue/merchants?quantity=1.1')
    end
  end
end
