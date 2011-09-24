require 'active_support/core_ext'
require 'json'

require File.join(PATHS::SOCKET_SERVER::LIB, 'interprocess_message')

require_relative 'config'
require_relative 'periodic_execution'
require_relative 'handlers/user_initiated_message'
require_relative 'handlers/bot_initiated_message'

require_relative 'pipe_connector'
require_relative 'subprocessor'

class BotBase
  include Config
  include PeriodicExecution
  include PipeConnector
  include Subprocessor

  include UserInitiatedMessageHandler
  include BotInitiatedMessageHandler

  def initialize
    connect_asyncronous_pipe
    fork_periodic_tasks
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

  def bot_request_class
    Object.const_get(self.class.to_s + "Request")
  end

  def new_bot_request_instance(message_hash)
    bot_request_class.new(self.class, message_hash)
  end
end
