class CreateOrderEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :order_events do |t|
      t.references :order, null: false, foreign_key: true
      t.string :from_status, null: false
      t.string :to_status, null: false
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :order_events, :from_status
    add_index :order_events, :to_status
  end
end
