FactoryBot.define do
  factory :invoice_item do
    quantity   { Faker::Number.decimal_part(digits: 1) }
    unit_price { Faker::Number.decimal(l_digits: 2) }
    invoice
    item
  end
end
