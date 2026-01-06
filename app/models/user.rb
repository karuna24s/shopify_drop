class User < ApplicationRecord
  has_many :claims, dependent: :destroy
  has_many :restock_notifications, dependent: :destroy
  has_many :orders, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  scope :vip, -> { where(vip: true) }
  scope :non_vip, -> { where(vip: false) }

  def vip?
    vip
  end
end
