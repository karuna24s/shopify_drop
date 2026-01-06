class CreateClaims < ActiveRecord::Migration[7.2]
  def change
    create_table :claims do |t|
      t.integer :user_id, null: false
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
    # This is the "One claim per user per product" rule
    add_index :claims, [ :user_id, :product_id ], unique: true
  end
end
