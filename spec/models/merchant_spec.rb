require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'relationships' do
    it { should have_many(:items).dependent(:destroy) }
    it { should have_many(:invoices).dependent(:destroy) }
    it { should have_many(:transactions).through(:invoices)}
    it { should have_many(:invoice_items).through(:invoices)}
  end

  describe 'name methods' do
    before(:each) do
      create(:merchant, name: "Jaskolski, Swift and Ebert")
      create(:merchant, name: "Lowe Group")
      create(:merchant, name: "Beier, Ritchie and Green")
      create(:merchant, name: "Haag-Wolf")
      create(:merchant, name: "Bayer, Bahringer and Schmitt")
      create(:merchant, name: "Wisoky Inc")
      create(:merchant, name: "O'Connell Group")
      create(:merchant, name: "Schowalter, Durgan and Nitzsche")
      create(:merchant, name: "Larson LLC")
      create(:merchant, name: "Mayer-Cremin")
      create(:merchant, name: "Yundt-Ernser")
      create(:merchant, name: "Wilkinson, Schamberger and Haag")
      create(:merchant, name: "Stark LLC")
      create(:merchant, name: "Leannon and Sons")
      create(:merchant, name: "Hirthe-Ernser")
      create(:merchant, name: "Torp Inc")
      create(:merchant, name: "Hartmann Group")
      create(:merchant, name: "Schneider, Purdy and Shields")
      create(:merchant, name: "Glover, Koss and Jenkins")
      create(:merchant, name: "McClure LLC")
    end

    describe '.find_all_by_name(name)' do
      it 'returns alphabetized merchants with name in name field' do
        expect(Merchant.find_all_by_name('group').count).to eq(3)
        expect(Merchant.find_all_by_name('group').first.name).to eq("Hartmann Group")
        expect(Merchant.find_all_by_name('group').last.name).to eq("O'Connell Group")
      end
    end

    describe '.find_by_name(name)' do
      it 'returns only the first entry when searching by name' do
        expect(Merchant.find_by_name('group').name).to eq("Hartmann Group")
      end

      it 'returns a merchant' do
        expect(Merchant.find_by_name('group')).to be_a(Merchant)
      end
    end
  end

  describe 'revenue calculations' do
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

      # Merchant 2, total revenue 1542.9
      @merchant_2 = create(:merchant)
      @m2_items   = create_list(:item, 20, merchant: @merchant_2)

      @m2_invoices    = create_list(:invoice, 15, merchant: @merchant_2)
      @m2_inv_items_1 = create_list(:invoice_item, 5, invoice: @m2_invoices[0], item: @m2_items[0], quantity: 2, unit_price: 12.34)
      @m2_inv_items_2 = create_list(:invoice_item, 5, invoice: @m2_invoices[1], item: @m2_items[1], quantity: 5,  unit_price: 56.78)
      @m2_inv_items_3 = create_list(:invoice_item, 5, invoice: @m2_invoices[-1], item: @m2_items[2], quantity: 15, unit_price: 22.22)

      @m2_transaction_1 = create(:transaction, invoice: @m2_invoices[0], result: 'success')
      @m2_transaction_2 = create(:transaction, invoice: @m2_invoices[1], result: 'success')
      @m2_transaction_3 = create(:transaction, invoice: @m2_invoices[-1], result: 'failed')

      # Merchant 3, total revenue 61.05
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

    describe '.sort_by_revenue' do
      it 'returns merchants and total revenue in order of highest revenue' do
        expect(Merchant.sort_by_revenue(3).length).to   eq(3)
        expect(Merchant.sort_by_revenue(3).first.id).to eq(@merchant_2.id)
        expect(Merchant.sort_by_revenue(3).last.id).to  eq(@merchant_3.id)
        expect(Merchant.sort_by_revenue(3).first).to be_a(Merchant)
        expect(Merchant.sort_by_revenue(3).first.revenue).to eq(1542.9)
      end
    end

    describe '#total_revenue' do
      it 'returns total revenue for a specific merchant' do
        expect(@merchant_1.total_revenue).to eq(333.25)
        expect(@merchant_2.total_revenue).to eq(1542.9)
      end
    end
  end

  describe '.sort_by_items_sold(limit_num)' do
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

      @merchant_4     = create(:merchant)
      @m4_item        = create(:item, merchant: @merchant_4)
      @m4_invoice     = create(:invoice, merchant: @merchant_4)
      @m4_inv_items_1 = create(:invoice_item, invoice: @m4_invoice, item: @m4_item, quantity: 2, unit_price: 3.33)
      @m4_transaction = create(:transaction, invoice: @m4_invoice, result: 'success')

      @merchant_5     = create(:merchant)
      @m5_item        = create(:item, merchant: @merchant_5)
      @m5_invoice     = create(:invoice, merchant: @merchant_5)
      @m5_inv_items_1 = create(:invoice_item, invoice: @m5_invoice, item: @m5_item, quantity: 1, unit_price: 3.33)
      @m5_transaction = create(:transaction, invoice: @m5_invoice, result: 'success')
    end

    it 'sorts merchants by number of items sold' do
      expect(Merchant.sort_by_items_sold(5).length).to eq(5)
      expect(Merchant.sort_by_items_sold(5).first).to  eq(@merchant_3)
      expect(Merchant.sort_by_items_sold(5).last).to   eq(@merchant_5)
      expect(Merchant.sort_by_items_sold(5).first.items_sold).to eq(60)
    end
  end
end
