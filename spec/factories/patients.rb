FactoryBot.define do
  factory :patient do
    association :tenant
    name { Faker::Name.name }
    birth_date { Faker::Date.birthday(min_age: 5, max_age: 80) }
    cpf { Faker::Number.number(digits: 11).to_s }
  end
end
