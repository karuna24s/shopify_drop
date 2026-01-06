class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.integer :inventory_count, null: false, default: 0

      t.timestamps
    end
    # This ensures inventory never goes below 0 at the DB level
    add_check_constraint :products, "inventory_count >= 0", name: "inventory_min_zero"
  end
end
