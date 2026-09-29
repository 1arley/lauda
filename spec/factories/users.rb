FactoryBot.define do
  factory :user do
    association :tenant
    name { Faker::Name.name }
    sequence(:email) { |n| "profissional#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    confirmed_at { Time.current }
    role { :professional }

    trait :saas_admin do
      role { :saas_admin }
    end

    trait :tenant_admin do
      role { :tenant_admin }
    end

    trait :professional do
      role { :professional }
    end

    trait :reviewer do
      role { :reviewer }
    end
  end
end
