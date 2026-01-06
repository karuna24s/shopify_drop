class CreateRestockNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :restock_notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.datetime :notified_at

      t.timestamps
    end

    # Prevent duplicate notification signups per user/product
    add_index :restock_notifications, [:user_id, :product_id], unique: true
  end
end
