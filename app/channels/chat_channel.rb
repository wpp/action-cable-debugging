class ChatChannel < ApplicationCable::Channel
  def subscribed
    Rails.logger.info "Subscribed"
    stream_from "channel_1"
  end

  def unsubscribed
    Rails.logger.info "Unsubscribed"
    # Any cleanup needed when channel is unsubscribed
  end

  def speak
    ActionCable.server.broadcast "channel_1", { content: 'Hello World' }
  end
end
