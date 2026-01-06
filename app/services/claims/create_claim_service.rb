module Claims
  class CreateClaimService
    VIP_THRESHOLD = 5

    def initialize(product_id:, user_id:)
      @product_id = product_id
      @user_id = user_id
    end

    def call
      Product.transaction do
        # Fail-fast check: Has this user already claimed ANY product?
        # This provides early feedback before we decrement inventory.
        # The unique index on user_id is the ultimate safeguard against race conditions.
        if Claim.exists?(user_id: @user_id)
          return { success: false, error: :global_limit_reached }
        end

        # Validate product and user exist
        product = Product.lock.find_by(id: @product_id)
        return { success: false, error: :product_not_found } unless product

        user = User.find_by(id: @user_id)
        return { success: false, error: :user_not_found } unless user

        # Out of stock check: Register for restock notification
        if product.inventory_count.zero?
          RestockNotification.find_or_create_by!(user_id: @user_id, product_id: @product_id)
          return { success: false, error: :out_of_stock }
        end

        # VIP-only check: Products with low inventory are reserved for VIP users
        if product.inventory_count <= VIP_THRESHOLD && !user.vip?
          return { success: false, error: :vip_only }
        end

        # ATOMIC UPDATE: This is the most important line for Shopify
        # It only decrements IF the inventory is > 0 in a single SQL statement.
        affected_rows = Product.where(id: @product_id)
                               .where("inventory_count > 0")
                               .update_all("inventory_count = inventory_count - 1")

        if affected_rows > 0
          Claim.create!(product_id: @product_id, user_id: @user_id)
          return { success: true }
        else
          return { success: false, error: :sold_out }
        end
      end
    rescue ActiveRecord::RecordNotUnique
      # Race condition caught by the unique index on user_id
      { success: false, error: :global_limit_reached }
    end
  end
end
