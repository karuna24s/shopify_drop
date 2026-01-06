class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.boolean :vip, default: false, null: false

      t.timestamps
    end

    add_index :users, :email, unique: true

    # Add foreign key constraint to claims table
    add_foreign_key :claims, :users
  end
end
