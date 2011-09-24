require 'active_support/core_ext'
require 'json'

require File.join(PATHS::SOCKET_SERVER::LIB, 'interprocess_message')

require_relative 'pipe_connector'
require_relative 'subprocessor'

class BotBase
  include PipeConnector
    include Subprocessor

  def self.inherited(subclass)
    bot_directory_name = subclass.name.underscore.gsub(/_bot/, '')
    bot_config = File.join(PATHS::SOCKET_SERVER::BOTS, bot_directory_name, "config.yml")

    if File.exists?(bot_config)
      subclass.instance_variable_set(:"@config", YAML::load(File.open(bot_config)))
    end
  end

  def self.config
    @config
  end

  def config
    self.class.config
  end

  def self.periodically(seconds, &block)
    @periodic_tasks ||= []
    @periodic_tasks << [seconds, block]
  end


  def initialize
    connect_asyncronous_pipe
    fork_periodic_tasks
    connect_incoming_pipe
    wait_for_incoming
  end

protected

  def fork_periodic_tasks
    return unless periodic_tasks

    periodic_tasks.each do |seconds, task_block|
      within_subprocess do
        loop do
          instance_eval &task_block
          sleep seconds
        end
      end
    end
  end

  def periodic_tasks
    self.class.instance_variable_get(:"@periodic_tasks")
  end

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

    interprocess_message_string = @incoming_pipe.gets.strip!
    interprocess_message = InterprocessMessage.from_json(interprocess_message_string)
    message_hash = interprocess_message.message

    case interprocess_message.class.name
    when "UserInitiatedInterprocessMessage"
      handle_user_initiated_message(interprocess_message)
    when "BotInitiatedInterprocessMessage"
      handle_bot_initiated_message(interprocess_message)
    else raise "Unknown InterprocessMessage type: '#{interprocess_message.type}'"
    end

    wait_for_incoming
  end

  def handle_user_initiated_message(interprocess_message)
    message_hash = process(interprocess_message.message)
    interprocess_message = UserInitiatedInterprocessMessage.new(message_hash: message_hash)

    connect_outgoing_pipe
    @outgoing_pipe.puts interprocess_message.to_json
    @outgoing_pipe.flush
  end

  def handle_bot_initiated_message(interprocess_message)
    event_name = interprocess_message.event_name
    bot_name = interprocess_message.bot_name
    raise "Got a bot-initiated message that wasn't addressed to me!" unless bot_name == self.class.to_s

    bot_request = new_bot_request_instance(interprocess_message.message)
    handler = bot_request_class.handler_for_event(event_name)
    raise "I have no handler for the event: '#{event_name}'" unless handler

    handler_response = bot_request.instance_eval &handler

    if interprocess_message.response_pipe_path
      response_pipe = connect_named_pipe(interprocess_message.response_pipe_path)
      response_pipe.puts handler_response
      response_pipe.flush
    end
  end

  def process(message_hash)
    modified_message = new_bot_request_instance(message_hash).process

    if modified_message != nil && modified_message != message_hash["data"]
      message_hash["data"] = modified_message
    end

    message_hash
  end

  def bot_request_class
    Object.const_get(self.class.to_s + "Request")
  end

  def new_bot_request_instance(message_hash)
    bot_request_class.new(self.class, message_hash)
  end
end
