require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'relationships' do
    it { should belong_to(:merchant) }
    it { should have_many(:invoice_items).dependent(:destroy) }
    it { should have_many(:invoices).through(:invoice_items) }
  end

  describe 'find by methods' do
    before(:each) do
      create(:item, name: "Good-morning Breaker", description: "lingering, creamy, musty, rubber, orange", unit_price: 78.84)
      create(:item, name: "Veranda Blend", description: "deep, juicy, pecan, lime, cashew", unit_price: 31.44)
      create(:item, name: "Good-morning Equinox", description: "dry, big, strawberry, pecan, musty", unit_price: 16.04)
      create(:item, name: "Strong Town", description: "muted, syrupy, liquorice, vanilla, cocoa powder", unit_price: 20.26)
      create(:item, name: "Café Cake", description: "deep, coating, hay, bittersweet chocolate, potato defect!", unit_price: 61.85)
      create(:item, name: "KrebStar Nuts", description: "deep, juicy, corriander, mandarin, coconut", unit_price: 12.76)
      create(:item, name: "Green America", description: "mild, velvety, bergamot, burnt sugar, olive", unit_price: 61.58)
      create(:item, name: "Split Been", description: "dirty, coating, burnt sugar, granola, bergamot", unit_price: 58.26)
      create(:item, name: "Major Cowboy", description: "bright, smooth, bittersweet chocolate, maple syrup, cantaloupe", unit_price: 28.15)
      create(:item, name: "Street Blend", description: "muted, creamy, jasmine, prune, kiwi", unit_price: 80.71)
      create(:item, name: "Kreb-Full-o Extract", description: "astringent, creamy, coconut, leathery, cherry", unit_price: 46.94)
      create(:item, name: "Green Enlightenment", description: "complex, coating, medicinal, rose hips, passion fruit", unit_price: 76.29)
      create(:item, name: "Veranda Town", description: "bright, velvety, orange blossom, honeydew, sweet pea", unit_price: 89.75)
      create(:item, name: "Evening Extract", description: "crisp, full, passion fruit, golden raisin, rubber", unit_price: 62.91)
      create(:item, name: "Morning Solstice", description: "vibrant, tea-like, peach, red grape, musty", unit_price: 52.07)
      create(:item, name: "Strong Light", description: "dry, smooth, clementine, molasses, rubber", unit_price: 49.24)
      create(:item, name: "Holiday Symphony", description: "vibrant, syrupy, mushroom, marzipan, clementine", unit_price: 94.82)
      create(:item, name: "Postmodern Cowboy", description: "unbalanced, tea-like, baggy, orange, vanilla", unit_price: 93.31)
      create(:item, name: "Kreb-Full-o Utopia", description: "dense, syrupy, olive, nutella, cocoa powder", unit_price: 36.86)
      create(:item, name: "Holiday Coffee", description: "juicy, silky, tobacco, medicinal, nougat", unit_price: 52.71)
    end

    describe '.find_all_by_name(name)' do
      it 'finds all items by name alphabetized' do
        expect(Item.find_all_by_name('good').length).       to eq(2)
        expect(Item.find_all_by_name('good').first).to      be_an(Item)
        expect(Item.find_all_by_name('good').first.name).to eq("Good-morning Breaker")
        expect(Item.find_all_by_name('good').last.name).to  eq("Good-morning Equinox")
      end
    end

    describe '.find_all_by_price(price_params)' do
      it 'finds all items by name alphabetized' do
        price_params = ({min_price: 60.00, max_price: 80.00})
        expect(Item.find_all_by_price(price_params).length).to eq(5)
        expect(Item.find_all_by_price(price_params).first).to  be_an(Item)
        expect(Item.find_all_by_price(price_params).first.name).to eq("Café Cake")
        expect(Item.find_all_by_price(price_params).last.name).to  eq("Green Enlightenment")
      end
    end

    describe '.find_by_min_price(price_params)' do
      it 'finds all items over min price' do
        price_params = ({min_price: 60.00, max_price: 80.00})
        expect(Item.find_by_min_price(price_params).length).to eq(9)
        expect(Item.find_by_min_price(price_params).first).to  be_an(Item)
      end
    end

    describe '.find_by_max_price(price_params)' do
      it 'finds all items under max price' do
        price_params = ({min_price: 60.00, max_price: 80.00})
        expect(Item.find_by_max_price(price_params).length).to eq(16)
        expect(Item.find_by_max_price(price_params).first).to  be_an(Item)
      end

      it 'returns all items if max price is nil' do
        expect(Item.find_by_max_price({}).length).to eq(20)
      end
    end
  end

  describe '.sort_by_revenue(limit_num)' do
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
      expect(Item.sort_by_revenue(3).length).to    eq(3)
      expect(Item.sort_by_revenue(3).first.id).to eq(@m2_items[1].id)
      expect(Item.sort_by_revenue(3).last.id).to  eq(@m3_items[0].id)
    end
  end
end
