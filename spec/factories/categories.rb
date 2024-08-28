FactoryBot.define do
  factory :category do
    name { Faker::Food.unique.dish }
  end
end
