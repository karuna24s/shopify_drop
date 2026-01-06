FactoryBot.define do
  factory :claim do
    association :user
    association :product
  end
end
