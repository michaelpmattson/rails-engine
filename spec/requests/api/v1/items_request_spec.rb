require 'rails_helper'

describe 'Items API' do
  before(:each) do
    merchant = create(:merchant)
    create_list(:item, 20, merchant: merchant)
  end

  it 'sends a list of items' do
    get '/api/v1/items'

    expect(response).to be_successful
  end
end
