class Product < ApplicationRecord
  has_many :claims, dependent: :destroy
  has_many :restock_notifications, dependent: :destroy
end
