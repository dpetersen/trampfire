require 'pathname'

class BotManager
  BotsPath = "bots"
  ActivatedBotsPath = BotsPath + "/activated"

  def initialize
    discover_active_bots
    connect_incoming_named_pipe
  end

  # Public: Allow activated bots to make modifications to a message.
  #
  # message - A Message.
  #
  # Returns nothing.
  def self.process_message(message)
    @instance ||= self.new
    @instance.process_message(message)
  end

  def process_message(message)
    interprocess_message = UserInitiatedInterprocessMessage.new(message: message)
    interprocess_message_string = pass_interprocess_message_through_bot_bus(interprocess_message)

    interprocess_message = InterprocessMessage.from_json(interprocess_message_string)
    message.final_message = interprocess_message.message["data"]
  end

protected

  def discover_active_bots
    @bots = Pathname.
      glob("#{PATHS::SOCKET_SERVER::ACTIVATED_BOTS}/*/").
      map { |i| i.basename.to_s }
  end

  def connect_incoming_named_pipe
    path = "#{BotsPath}/bot_manager_incoming"
    @incoming_pipe = NamedPipe.for_reading(path)
  end

  # Pass InterprocessMessage JSON through each activated bot.
  #
  # interprocess_message - An InterprocessMessage instance.
  #
  # Returns a JSON string reprensentation of the potentially-modified
  # InterprocessMessage.
  def pass_interprocess_message_through_bot_bus(interprocess_message)
    @bots.inject(interprocess_message.to_json) do |passed_interprocess_message_string, bot_directory|
      bot_pipe = NamedPipe.for_writing_for_bot(bot_directory)
      bot_pipe.write passed_interprocess_message_string

      @incoming_pipe.read
    end
  end
end
