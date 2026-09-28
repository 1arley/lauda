FactoryBot.define do
  factory :instrument_application do
    association :assessment
    association :instrument_version
    association :applied_by, factory: :user
    status { :pending }
  end
end
