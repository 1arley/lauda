FactoryBot.define do
  factory :patient do
    association :tenant
    name { Faker::Name.name }
    birth_date { Faker::Date.birthday(min_age: 5, max_age: 80) }
    sequence(:cpf) { |n| format('%011d', n) }
  end
end
