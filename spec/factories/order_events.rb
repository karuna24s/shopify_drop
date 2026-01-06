FactoryBot.define do
  factory :order_event do
    order { nil }
    from_status { "MyString" }
    to_status { "MyString" }
    metadata { "" }
  end
end
