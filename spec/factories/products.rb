FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    inventory_count { 10 }

    trait :low_stock do
      inventory_count { 3 }
    end

    trait :high_stock do
      inventory_count { 10 }
    end

    trait :sold_out do
      inventory_count { 0 }
    end
  end
end

