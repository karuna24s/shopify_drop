class ClaimStatusChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    # Each user gets their own private stream
    stream_from "claim_status_#{params[:user_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
