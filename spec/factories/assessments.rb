FactoryBot.define do
  factory :assessment do
    association :tenant
    association :patient
    association :owner, factory: :user
    title { "Avaliação #{Faker::Lorem.word}" }
    status { :draft }
  end
end
