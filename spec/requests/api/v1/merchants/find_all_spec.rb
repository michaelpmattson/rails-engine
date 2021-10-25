require 'rails_helper'

describe 'merchants/find api' do
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

  it 'returns all merchants with search word in the name, case insensitive' do
    get('/api/v1/merchants/find_all?name=group')

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

    expect(merchants[:data].first[:attributes][:name]).to eq("Hartmann Group")
    expect(merchants[:data].last[:attributes][:name]).to eq("O'Connell Group")
  end

  it 'returns empty data array if there is no result' do
    get('/api/v1/merchants/find_all?name=ailsuefgliasugf')

    expect(response).to be_successful

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(merchants).to have_key(:data)
    expect(merchants[:data]).to be_an(Array)
    expect(merchants[:data]).to eq([])
  end
end
