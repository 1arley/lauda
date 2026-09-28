FactoryBot.define do
  factory :tenant do
    name { Faker::Company.name }
    subdomain { Faker::Internet.domain_name }
  end
end
