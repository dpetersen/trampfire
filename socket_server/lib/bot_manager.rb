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
    interprocess_message = InterprocessMessage.new(:user_initiated, message: message)
    interprocess_message_string = pass_interprocess_message_through_bot_bus(interprocess_message)

    interprocess_message = InterprocessMessage.from_json(interprocess_message_string)
    message.final_message = interprocess_message.message["data"]
  end

protected

  def discover_active_bots
    @bots = Pathname.
      glob("#{ActivatedBotsPath}/*/").
      map { |i| i.basename.to_s }
  end

  def connect_incoming_named_pipe
    path = "#{BotsPath}/bot_manager_incoming"
    `mkfifo #{path}` unless File.exist?(path)
    @incoming_pipe = open(path, "r+")
  end

  # Pass InterprocessMessage JSON through each activated bot.
  #
  # interprocess_message - An InterprocessMessage instance.
  #
  # Returns a JSON string reprensentation of the potentially-modified
  # InterprocessMessage.
  def pass_interprocess_message_through_bot_bus(interprocess_message)
    @bots.inject(interprocess_message.to_json) do |passed_interprocess_message_string, bot_directory|
      bot_pipe = open("#{ActivatedBotsPath}/#{bot_directory}/incoming", "w+")
      bot_pipe.puts passed_interprocess_message_string
      bot_pipe.flush

      @incoming_pipe.gets
    end
  end
end
