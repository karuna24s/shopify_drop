class ClaimsController < ApplicationController
  # We skip CSRF for now so we can test with curl/Postman easily
  skip_before_action :verify_authenticity_token

  def index
    @product = Product.first || Product.create!(name: "Standard Tee", inventory_count: 10)
  end

  # def create
  #   # product_id = params[:product_id]
  #   # user_id = params[:user_id]

  #   # if product_id.blank? || user_id.blank?
  #   #   return render json: { error: "Missing product_id or user_id" }, status: :bad_request
  #   # end

  #   # # This pushes the task to Redis for Sidekiq to pick up
  #   # ProcessClaimJob.perform_later(product_id, user_id)

  #   # # Return 202 Accepted - the standard for "we started the work"
  #   # render json: {
  #   #   status: "Processing",
  #   #   message: "You're in the queue! We'll notify you via WebSockets."
  #   # }, status: :accepted

  #   # # Senior Move: Check if they already have one before even hitting Redis/Sidekiq
  #   # if Claim.exists?(user_id: params[:user_id], product_id: params[:product_id])
  #   #   return render json: { error: "Already claimed" }, status: :conflict
  #   # end

  #   # ProcessClaimJob.perform_later(params[:product_id], params[:user_id])
  #   # render json: { status: "Processing" }, status: :accepted

  #   # if Claim.exists?(user_id: params[:user_id], product_id: params[:product_id])
  #   #   # Instead of just a 409, let's give the user a helpful message
  #   #   return render json: {
  #   #     status: "error",
  #   #     message: "You've already claimed this item! Check your email."
  #   #   }, status: :conflict
  #   # end

  #   # ProcessClaimJob.perform_later(params[:product_id], params[:user_id])
  #   # render json: { status: "success" }, status: :accepted

  #   if Claim.exists?(user_id: params[:user_id], product_id: params[:product_id])
  #     # Instead of just 409, we broadcast the error immediately
  #     # so the "stuck" UI updates even if no job is created.
  #     ActionCable.server.broadcast("claim_status_#{params[:user_id]}", { success: false, error: "already_claimed" })
  #     return render json: { error: "already_claimed" }, status: :conflict
  #   end

  #   ProcessClaimJob.perform_later(params[:product_id], params[:user_id])
  #   render json: { status: "Accepted" }, status: :accepted
  # end

  # def create
  #   if Claim.exists?(user_id: params[:user_id], product_id: params[:product_id])
  #     # The browser is waiting! We must broadcast here too.
  #     ActionCable.server.broadcast("claim_status_#{params[:user_id]}", { success: false, error: "already_claimed" })
  #     return render json: { error: "already_claimed" }, status: :conflict
  #   end

  #   ProcessClaimJob.perform_later(params[:product_id], params[:user_id])
  #   render json: { status: "Accepted" }, status: :accepted
  # end

  # def create
  #   user_id = params[:user_id].to_s # Ensure it's a string

  #   if Claim.exists?(user_id: user_id, product_id: params[:product_id])
  #     # Broadcast immediately so the UI doesn't stay on "Processing"
  #     ActionCable.server.broadcast("claim_status_#{user_id}", { success: false, error: "already_claimed" })
  #     return render json: { error: "already_claimed" }, status: :conflict
  #   end

  #   ProcessClaimJob.perform_later(params[:product_id], user_id)
  #   render json: { status: "Accepted" }, status: :accepted
  # end

  # def create
  #   user_id = params[:user_id]
  #   product_id = params[:product_id]

  #   # Check before enqueuing to keep the Sidekiq queue clean
  #   if Claim.exists?(user_id: user_id)
  #     ActionCable.server.broadcast("claim_status_#{user_id}", { success: false, error: "You have already claimed an item in this drop." })
  #     return render json: { error: "Already claimed" }, status: :conflict
  #   end

  #   ProcessClaimJob.perform_later(product_id, user_id)
  #   render json: { status: "Accepted" }, status: :accepted
  # end
  def create
    user_id = params[:user_id].to_s # Force to string
    product_id = params[:product_id]

    # Debugging: This will show up in your 'bin/rails s' terminal
    Rails.logger.info "DEBUG: Received request for User: #{user_id}"

    if Claim.exists?(user_id: user_id)
      ActionCable.server.broadcast("claim_status_#{user_id}", { success: false, error: "already_claimed" })
      return render json: { error: "already_claimed" }, status: :conflict
    end

    ProcessClaimJob.perform_later(product_id, user_id)
    render json: { status: "Accepted" }, status: :accepted
  end
end