FactoryBot.define do
  factory :item do
    name { Faker::Commerce.product_name }
    description { Faker::Hipster.sentence(word_count: 3) }
    unit_price { Faker::Number.between(from: 1, to: 10000)}
  end
end