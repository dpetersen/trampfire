module BotInitiatedMessageHandler

protected

  def handle_bot_initiated_message(interprocess_message)
    event_name = interprocess_message.event_name
    bot_name = interprocess_message.bot_name
    raise "Got a bot-initiated message that wasn't addressed to me!" unless bot_name == self.short_bot_name

    bot_request = new_bot_request_instance(interprocess_message.message)
    handler = bot_request_class.handler_for_event(event_name)
    raise "I have no handler for the event: '#{event_name}'" unless handler

    handler_response = \
      if handler.is_a?(Module)
        bot_request.singleton_class.send(:include, handler)
        bot_request.handle
      else
        bot_request.instance_eval &handler
      end

    if interprocess_message.response_pipe
      interprocess_message.response_pipe.write handler_response
    end
  end
end
