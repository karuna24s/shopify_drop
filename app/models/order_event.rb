class OrderEvent < ApplicationRecord
  belongs_to :order

  validates :from_status, presence: true
  validates :to_status, presence: true
end
