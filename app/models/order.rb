class Order < ApplicationRecord
  STATUSES = %w[pending confirmed processing shipped delivered cancelled].freeze

  belongs_to :user
  has_many :order_events, dependent: :destroy

  validates :status, presence: true, inclusion: { in: STATUSES }

  after_update :create_status_change_event, if: :saved_change_to_status?

  private

  def create_status_change_event
    # The update and event creation are already wrapped in a transaction
    # by ActiveRecord's after_update callback (runs within the save transaction)
    order_events.create!(
      from_status: status_before_last_save,
      to_status: status,
      metadata: {
        changed_at: Time.current
      }
    )
  end
end
