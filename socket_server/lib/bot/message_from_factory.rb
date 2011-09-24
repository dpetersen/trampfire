class MessageFromFactory
  def initialize(tag_name, bot_name, original_message)
    @tag_name = tag_name
    @bot_name = bot_name
    @original_message = original_message
  end

  def message
    NamedPipe.with_anonymous_pipe_for_reading do |pipe|
      interprocess_message = build_interprocess_message(pipe)
      interprocess_message.send_to_message_factory_pipe

      pipe.read_json
    end
  end

  protected

  def build_interprocess_message(response_pipe)
    MessageFactoryInterprocessMessage.new(
      response_pipe,
      message_hash: {
        tag_name: @tag_name,
        original_message: @original_message,
        bot: @bot_name
      }
    )
  end
end
