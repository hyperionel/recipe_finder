FactoryBot.define do
  factory :author do
    name { Faker::Name.unique.name }
  end
end
