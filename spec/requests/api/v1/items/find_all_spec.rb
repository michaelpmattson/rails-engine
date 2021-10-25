require 'rails_helper'

describe 'items/find_all api' do
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

  it 'returns all items with search word in the name, case insensitive' do
    get('/api/v1/items/find_all?name=good')

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

    expect(items[:data].first[:attributes][:name]).to eq("Good-morning Breaker")
    expect(items[:data].last[:attributes][:name]).to eq("Good-morning Equinox")
  end

  it 'returns empty data array if there is no result' do
    get('/api/v1/items/find_all?name=ailsuefgliasugf')

    expect(response).to be_successful

    items = JSON.parse(response.body, symbolize_names: true)

    expect(items).to have_key(:data)
    expect(items[:data]).to be_an(Array)
    expect(items[:data]).to eq([])
  end

  it 'can find by min_price' do
    get('/api/v1/items/find_all?min_price=60.00')

    expect(response).to be_successful

    items = JSON.parse(response.body, symbolize_names: true)

    expect(items).to have_key(:data)
    expect(items[:data]).to be_an(Array)
    expect(items[:data].first[:attributes][:name]).to eq("Café Cake")
    expect(items[:data].last[:attributes][:name]).to eq("Veranda Town")
  end

  it 'can find by max_price' do
    get('/api/v1/items/find_all?max_price=60.00')

    expect(response).to be_successful

    items = JSON.parse(response.body, symbolize_names: true)

    expect(items).to have_key(:data)
    expect(items[:data]).to be_an(Array)
    expect(items[:data].first[:attributes][:name]).to eq("Good-morning Equinox")
    expect(items[:data].last[:attributes][:name]).to eq("Veranda Blend")
  end
  
  # it 'can find by min_price and max_price' do
  #   get('/api/v1/items/find_all?min_price=60.00&max_price=80.00')
  #
  #   expect(response).to be_successful
  #
  #   items = JSON.parse(response.body, symbolize_names: true)
  #
  #   expect(items).to have_key(:data)
  #   expect(items[:data]).to be_an(Array)
  #   expect(items[:data].first[:attributes][:name]).to eq("Café Cake")
  #   expect(items[:data].last[:attributes][:name]).to eq("Green Enlightenment")
  # end
  #
  # it 'errors when a name and a price are both entered' do
  #
  # end
end
