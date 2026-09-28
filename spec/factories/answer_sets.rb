FactoryBot.define do
  factory :answer_set do
    association :instrument_application
    subtest_name { 'Semelhanças' }
    answers { { '1' => 1, '2' => 1, '3' => 1 } }
    position { 0 }
  end
end
