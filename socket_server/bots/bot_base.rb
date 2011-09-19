require 'active_support/core_ext'
require 'json'

class BotBase
  BotsRoot = File.dirname(__FILE__)

  def self.inherited(subclass)
    bot_directory_name = subclass.name.underscore.gsub(/_bot/, '')
    bot_config = File.join(BotsRoot, bot_directory_name, "config.yml")

    if File.exists?(bot_config)
      subclass.instance_variable_set(:"@config", YAML::load(File.open(bot_config)))
    end
  end

  def self.config
    @config
  end

  def initialize
    connect_incoming_pipe
    wait_for_incoming
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

  def process(message_json)
    message_hash = deserialize_message_json(message_json)
    request_klass = Object.const_get(self.class.to_s + "Request")
    modified_message = request_klass.new(self.class, message_hash).process

    if modified_message != nil && modified_message != message_hash["data"]
      serialize_message_hash(
        message_hash,
        modified_message
      )
    else message_json
    end
  end

  def deserialize_message_json(message)
    JSON.parse(message)
  end

  def serialize_message_hash(message_hash, data)
    message_hash["data"] = data
    message_hash.to_json
  end
end
