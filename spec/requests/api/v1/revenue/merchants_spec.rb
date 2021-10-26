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
end
