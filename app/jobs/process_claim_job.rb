class ProcessClaimJob < ApplicationJob
  queue_as :default

  # def perform(product_id, user_id)
  #   # # 1. Execute the Atomic Service we built in Phase 1
  #   # result = Claims::CreateClaimService.new(
  #   #   product_id: product_id,
  #   #   user_id: user_id
  #   # ).call

  #   # # 2. Broadcast the result to the specific user via ActionCable
  #   # ActionCable.server.broadcast(
  #   #   "claim_status_#{user_id}",
  #   #   result # This sends { success: true } or { success: false, error: ... }
  #   # )

  #   # 1. Convert to integers before passing to the service
  #   result = Claims::CreateClaimService.new(
  #     product_id: product_id.to_i,
  #     user_id: user_id.to_i
  #   ).call

  #   # Senior Tip: Log exactly what we are shouting into the void
  #   Rails.logger.info "Broadcasting to claim_status_#{user_id} with #{result}"

  #   # 2. Broadcast using a string ID to match the JS subscription
  #   ActionCable.server.broadcast("claim_status_#{user_id.to_s}", result)
  # end

  # def perform(product_id, user_id)
  #   result = Claims::CreateClaimService.new(
  #     product_id: product_id.to_i,
  #     user_id: user_id.to_i
  #   ).call

  #   # Force user_id to string to ensure the 'room' name matches the JS subscription
  #   ActionCable.server.broadcast("claim_status_#{user_id.to_s}", result)
  # end

  # def perform(product_id, user_id)
  #   result = Claims::CreateClaimService.new(
  #     product_id: product_id.to_i,
  #     user_id: user_id.to_i
  #   ).call

  #   Rails.logger.info "Broadcasting result to User #{user_id}: #{result}"

  #   # Broadcase to the string-based channel name
  #   ActionCable.server.broadcast("claim_status_#{user_id.to_s}", result)
  # end

  def perform(product_id, user_id)
    # This should appear in your SIDEKIQ terminal
    puts "!!! SIDEKIQ IS PROCESSING USER: #{user_id} !!!"

    result = Claims::CreateClaimService.new(
      product_id: product_id.to_i,
      user_id: user_id.to_i
    ).call

    # Force the broadcast room to match the string ID
    ActionCable.server.broadcast("claim_status_#{user_id}", result)
    puts "!!! BROADCAST COMPLETE FOR USER: #{user_id} !!!"
  end
end
