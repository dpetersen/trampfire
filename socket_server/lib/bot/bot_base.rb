require 'active_support/core_ext'
require 'json'

require File.join(PATHS::SOCKET_SERVER::LIB, 'interprocess_message')

require_relative 'config'
require_relative 'periodic_execution'
require_relative 'subprocessor'
require_relative 'handlers/user_initiated_message'
require_relative 'handlers/bot_initiated_message'

class BotBase
  include Config
  include PeriodicExecution
  include Subprocessor

  include UserInitiatedMessageHandler
  include BotInitiatedMessageHandler

  def initialize
    fork_periodic_tasks
    wait_for_incoming
  end

protected

  def autoconnect_database
    require 'logger'
    require 'active_record'

    ActiveRecord::Base.establish_connection(
      adapter: "mysql2",
      host: "localhost",
      username: "root",
      password: "",
      database: long_bot_name,
      encoding: "utf8"
    )
    ActiveRecord::Base.logger = Logger.new(STDOUT)
  end

  def outgoing_pipe
    return @outgoing_pipe if @outgoing_pipe

    path = File.join(PATHS::SOCKET_SERVER::BOTS, "bot_manager_incoming")
    @outgoing_pipe = NamedPipe.for_writing(path)
  end

  def incoming_pipe
    return @incoming_pipe if @incoming_pipe

    path = File.join(PATHS::SOCKET_SERVER::ACTIVATED_BOTS, short_bot_name, "incoming")
    @incoming_pipe = NamedPipe.for_reading(path)
  end

  def wait_for_incoming
    puts "Waiting"

    interprocess_message_string = incoming_pipe.read.strip!
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

  def long_bot_name
    self.class.name.underscore
  end

  def short_bot_name
    long_bot_name.gsub(/_bot/, "")
  end

  def bot_request_class
    Object.const_get(self.class.to_s + "Request")
  end

  def new_bot_request_instance(message_hash)
    bot_request_class.new(self, self.class, message_hash)
  end
end
