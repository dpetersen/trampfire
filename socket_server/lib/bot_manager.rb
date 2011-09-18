require 'pathname'

class BotManager
  BotsPath = "bots"

  def initialize
    @bots = Pathname.glob("#{BotsPath}/*/").map { |i| i.basename.to_s }
    connect_incoming_named_pipe
  end

  def process(message)
    processed_message_json = pass_message_json_through_bot_bus(message)
    message.final_message = JSON.parse(processed_message_json)["data"]
  end

  def self.process(message)
    @instance ||= self.new
    @instance.process(message)
  end

protected

  def connect_incoming_named_pipe
    path = "#{BotsPath}/bot_manager_incoming"
    `mkfifo #{path}` unless File.exist?(path)
    @incoming_pipe = open(path, "r+")
  end

  def pass_message_json_through_bot_bus(message)
    @bots.inject(message.as_json.to_json) do |passed_message, bot_directory|
      bot_pipe = open("#{BotsPath}/#{bot_directory}/incoming", "w+")
      bot_pipe.puts passed_message
      bot_pipe.flush

      @incoming_pipe.gets
    end
  end
end
