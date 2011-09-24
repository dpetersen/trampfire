class MessageFromFactory
  def initialize(tag_name, bot_name, original_message)
    @response_pipe = NamedPipe.anonymous_for_writing

    build_interprocess_message(tag_name, bot_name, original_message)
  end

  def message
    NamedPipe.message_factory_pipe.write(@interprocess_message.to_json)
    message_string = @response_pipe.read

    JSON.parse(message_string)
  end

  protected

  def build_interprocess_message(tag_name, bot_name, original_message)
    @interprocess_message = \
      MessageFactoryInterprocessMessage.new(
        @response_pipe,
        message_hash: {
          tag_name: tag_name,
          original_message: original_message,
          bot: bot_name
        }
      )
  end
end
