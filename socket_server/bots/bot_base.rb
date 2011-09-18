require 'json'

class BotBase
  def initialize
    connect_incoming_pipe

    wait_for_incoming
  end

  def process(message_json)
    message_hash = deserialize_message_json(message_json)
    original_message = message_hash["data"]

    modified_message = modify_message(original_message)

    if modified_message != nil && modified_message != original_message
      serialize_message_hash(
        message_hash,
        modified_message
      )
    else message_json
    end
  end

protected

  def connect_incoming_pipe
    path = "incoming"
    `mkfifo #{path}` unless File.exist?(path)
    @incoming_pipe = open("incoming", "r+")
  end

  # Called at message time, not on initialize.  If the pipe doesn't
  # exist, Ruby creates a file in its place.  On first launch, it
  # probably won't be there by the time this initializes.
  # 
  # The running bots will technically be in bots/activated.
  def connect_outgoing_pipe
    return if @outgoing_pipe

    path = "../bot_manager_incoming"
    if File.exist?(path)
      @outgoing_pipe = open(path, "w+")
    else raise "Can't connect to bot manager's named pipe!"
    end
  end

  def wait_for_incoming
    puts "Waiting"

    message = @incoming_pipe.gets.strip!
    puts "Got message: #{message}"
    message = process(message)

    puts "Message modded to: #{message}"
    connect_outgoing_pipe
    @outgoing_pipe.puts message
    @outgoing_pipe.flush

    wait_for_incoming
  end

  def deserialize_message_json(message)
    JSON.parse(message)
  end

  def serialize_message_hash(message_hash, data)
    message_hash["data"] = data
    message_hash.to_json
  end
end
