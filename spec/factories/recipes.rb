FactoryBot.define do
  factory :recipe do
    title { Faker::Food.unique.dish }
    cook_time { Faker::Number.between(from: 5, to: 120) }
    prep_time { Faker::Number.between(from: 5, to: 60) }
    ratings { Faker::Number.decimal(l_digits: 1, r_digits: 1) }
    cuisine { Faker::Food.ethnic_category }
    image { Faker::Internet.url(host: 'example.com', path: '/recipe_image.jpg') }
    association :category
    association :author
    ingredient_data { { quantities: Faker::Food.measurement } }
  end
end
