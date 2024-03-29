module UserInitiatedMessageHandler

protected

  def handle_user_initiated_message(interprocess_message)
    message_hash = process_in_request_class(interprocess_message.message)
    interprocess_message = UserInitiatedInterprocessMessage.new(message_hash: message_hash)

    outgoing_pipe.write interprocess_message.to_json
  end

  def process_in_request_class(message_hash)
    modified_message = new_bot_request_instance(message_hash).process_user_initiated_message

    if modified_message != nil && modified_message != message_hash["data"]
      message_hash["data"] = modified_message
    end

    message_hash
  end
end
