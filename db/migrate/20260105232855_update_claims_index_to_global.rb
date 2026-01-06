class UpdateClaimsIndexToGlobal < ActiveRecord::Migration[7.2]
  def change
    # Use if_exists: true to prevent the "No indexes found" crash
    remove_index :claims, column: [:user_id, :product_id], if_exists: true

    # Add the global per-user index
    # We add if_not_exists for safety during the pair-programming session
    add_index :claims, :user_id, unique: true, if_not_exists: true
  end
end