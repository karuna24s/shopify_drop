FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    vip { false }

    trait :vip do
      vip { true }
    end
  end
end
