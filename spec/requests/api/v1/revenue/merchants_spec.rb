require 'rails_helper'

RSpec.describe 'revenue for merchants api' do
  describe 'total revenue for a merchant (the show action)' do
    before(:each) do
      @merchant_1 = create(:merchant)
      @m1_items   = create_list(:item, 20, merchant: @merchant_1)
      @merchant_2 = create(:merchant)
      @m2_items   = create_list(:item, 20, merchant: @merchant_2)
      @merchant_3 = create(:merchant)
      @m3_items   = create_list(:item, 20, merchant: @merchant_3)

      @m1_invoices    = create_list(:invoice, 15, merchant: @merchant_1)
      @m1_inv_items_1 = create_list(:invoice_item, 5, invoice: @m1_invoices[0], item: @m1_items[0], quantity: 2, unit_price: 5.55)
      @m1_inv_items_2 = create_list(:invoice_item, 5, invoice: @m1_invoices[1], item: @m1_items[1], quantity: 5,  unit_price: 11.11)
      @m1_inv_items_3 = create_list(:invoice_item, 5, invoice: @m1_invoices[-1], item: @m1_items[2], quantity: 15, unit_price: 22.22)

      @m1_transaction_1 = create(:transaction, invoice: @m1_invoices[0], result: 'success')
      @m1_transaction_2 = create(:transaction, invoice: @m1_invoices[1], result: 'success')
      @m1_transaction_3 = create(:transaction, invoice: @m1_invoices[-1], result: 'failed')
    end

    it 'gets one merchants total revenue' do
      get("/api/v1/revenue/merchants/#{@merchant_1.id}")

      expect(response).to be_successful

      m1_total = JSON.parse(response.body, symbolize_names: true)

      expect(m1_total).to have_key(:data)

      expect(m1_total[:data]).to have_key(:id)
      expect(m1_total[:data][:id]).to be_a(String)

      expect(m1_total[:data]).to have_key(:type)
      expect(m1_total[:data][:type]).to eq('merchant_revenue')

      expect(m1_total[:data]).to have_key(:attributes)
      expect(m1_total[:data][:attributes]).to have_key(:revenue)
      expect(m1_total[:data][:attributes][:revenue]).to eq(333.25)
    end

    it 'throws a 404 when the user id is bad' do
      get("/api/v1/revenue/merchants/liefgousileugf")

      expect(response.status).to be(404)

      items = JSON.parse(response.body, symbolize_names: true)

      expect(items[:error]).to eq('Sorry, that merchant does not exist')
    end
  end

  describe 'merchants with most revenue' do
    before(:each) do
      # Merchant 1, total revenue 333.25
      @merchant_1 = create(:merchant)
      @m1_items   = create_list(:item, 20, merchant: @merchant_1)

      @m1_invoices    = create_list(:invoice, 15, merchant: @merchant_1)
      @m1_inv_items_1 = create_list(:invoice_item, 5, invoice: @m1_invoices[0], item: @m1_items[0], quantity: 2, unit_price: 5.55)
      @m1_inv_items_2 = create_list(:invoice_item, 5, invoice: @m1_invoices[1], item: @m1_items[1], quantity: 5,  unit_price: 11.11)
      @m1_inv_items_3 = create_list(:invoice_item, 5, invoice: @m1_invoices[-1], item: @m1_items[2], quantity: 15, unit_price: 22.22)

      @m1_transaction_1 = create(:transaction, invoice: @m1_invoices[0], result: 'success')
      @m1_transaction_2 = create(:transaction, invoice: @m1_invoices[1], result: 'success')
      @m1_transaction_3 = create(:transaction, invoice: @m1_invoices[-1], result: 'failed')

      # Merchant 1, total revenue 333.25
      @merchant_2 = create(:merchant)
      @m2_items   = create_list(:item, 20, merchant: @merchant_2)

      @m2_invoices    = create_list(:invoice, 15, merchant: @merchant_2)
      @m2_inv_items_1 = create_list(:invoice_item, 5, invoice: @m2_invoices[0], item: @m2_items[0], quantity: 2, unit_price: 12.34)
      @m2_inv_items_2 = create_list(:invoice_item, 5, invoice: @m2_invoices[1], item: @m2_items[1], quantity: 5,  unit_price: 56.78)
      @m2_inv_items_3 = create_list(:invoice_item, 5, invoice: @m2_invoices[-1], item: @m2_items[2], quantity: 15, unit_price: 22.22)

      @m2_transaction_1 = create(:transaction, invoice: @m2_invoices[0], result: 'success')
      @m2_transaction_2 = create(:transaction, invoice: @m2_invoices[1], result: 'success')
      @m2_transaction_3 = create(:transaction, invoice: @m2_invoices[-1], result: 'failed')

      # Merchant 1, total revenue 333.25
      @merchant_3 = create(:merchant)
      @m3_items   = create_list(:item, 20, merchant: @merchant_3)

      @m3_invoices    = create_list(:invoice, 15, merchant: @merchant_3)
      @m3_inv_items_1 = create_list(:invoice_item, 5, invoice: @m3_invoices[0], item: @m3_items[0], quantity: 2, unit_price: 3.33)
      @m3_inv_items_2 = create_list(:invoice_item, 5, invoice: @m3_invoices[1], item: @m3_items[1], quantity: 5,  unit_price: 1.11)
      @m3_inv_items_3 = create_list(:invoice_item, 5, invoice: @m3_invoices[-1], item: @m3_items[2], quantity: 15, unit_price: 22.22)

      @m3_transaction_1 = create(:transaction, invoice: @m3_invoices[0], result: 'success')
      @m3_transaction_2 = create(:transaction, invoice: @m3_invoices[1], result: 'success')
      @m3_transaction_3 = create(:transaction, invoice: @m3_invoices[-1], result: 'failed')
    end

    it 'returns merchants and total revenue in order of highest revenue' do
      get('/api/v1/revenue/merchants?quantity=3')

      expect(response).to be_successful

      # revenues = JSON.parse(response.body, symbolize_names: true)
      #
      # expect(revenues).to have_key(:data)
      # expect(revenues[:data]).to be_an(Array)
      #
      # revenues[:data].each do |merchant|
      #   expect(merchant).to have_key(:id)
      #   expect(merchant[:id]).to be_a(String)
      #
      #   expect(merchant).to have_key(:type)
      #   expect(merchant[:type]).to eq('merchant_name_revenue')
      #
      #   expect(merchant).to have_key(:attributes)
      #   expect(merchant[:attributes]).to be_a(Hash)
      #
      #   expect(merchant[:attributes]).to have_key(:name)
      #   expect(merchant[:attributes][:name]).to be_a(String)
      #
      #   expect(merchant[:attributes]).to have_key(:revenue)
      #   expect(merchant[:attributes][:revenue]).to be_a(Float)
      # end
      #
      # expect(revenues[:data].count).to      eq(3)
      # expect(revenues[:data].first[:id]).to eq(@merchant_2.id)
      # expect(revenues[:data].last[:id]).to  eq(@merchant_3.id)
    end

    xit 'can limit the number of merchants returned' do
      get('/api/v1/revenue/merchants?quantity=2')

    end

    xit 'errors when no quantity param is entered' do
      get('/api/v1/revenue/merchants')

    end

    xit 'errors when quantity is 0 or lower' do
      get('/api/v1/revenue/merchants?quantity=0')

      get('/api/v1/revenue/merchants?quantity=-1')
    end

    xit 'errors when quantity is not an integer' do
      get('/api/v1/revenue/merchants?quantity=potato')

      get('/api/v1/revenue/merchants?quantity=1.1')
    end
  end
end
