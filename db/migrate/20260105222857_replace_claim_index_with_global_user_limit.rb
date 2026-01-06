class ReplaceClaimIndexWithGlobalUserLimit < ActiveRecord::Migration[7.2]
  def change
    # Remove the redundant composite index - the new user_id unique index is stricter
    remove_index :claims, name: 'index_claims_on_user_id_and_product_id'

    # Add unique index on user_id to enforce global limit of 1 claim per user
    add_index :claims, :user_id, unique: true, name: 'index_claims_on_user_id_unique'
  end
end
