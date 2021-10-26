FactoryBot.define do
  factory :transaction do
    credit_card_number          { '9999999999999999' }
    credit_card_expiration_date { '9999' }
    result                      { 'success' }
    invoice
  end
end
