FactoryBot.define do
  factory :tenant do
    name { Faker::Company.name }
    # Faker repete domínios com frequência; a unicidade é validada no model e quebrava
    # specs aleatoriamente conforme a seed.
    sequence(:subdomain) { |n| "tenant-#{n}" }
  end
end
