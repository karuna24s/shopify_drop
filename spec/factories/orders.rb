FactoryBot.define do
  factory :order do
    association :user
    status { 'pending' }
  end
end
