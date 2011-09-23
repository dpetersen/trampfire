require 'pry'

require 'fcntl'
require 'eventmachine'
require 'em-websocket'
require './lib/libs'

require 'active_record'
require '../models/models'
require '../database_config'

ActiveRecord::Base.establish_connection(
  adapter: DatabaseConfig.adapter,
  host: DatabaseConfig.host,
  username: DatabaseConfig.username,
  password: DatabaseConfig.password,
  database: DatabaseConfig.database
)

AllClients = Clients.new

asynchronous_incoming_pipe_path = 'bots/asynchronous_incoming_pipe_path'
AsynchronousMessageHandler.create_incoming_pipe(asynchronous_incoming_pipe_path)

message_factory_incoming_pipe_path = 'message_factory_incoming_pipe'
MessageFactoryHandler.create_incoming_pipe(message_factory_incoming_pipe_path)

# For OSX support, apparently
EventMachine.kqueue = true if EventMachine.kqueue?

EventMachine.run do

  EventMachine::WebSocket.start(host: "0.0.0.0", port: 8080) do |ws|
    ws.onopen do
      client = Client.new(ws)
      AllClients.add(client)
      AllClients.system_broadcast "#{client.display_name} has connected."
      AllClients.roster_update
    end

    ws.onclose do
      client = AllClients.find_by_socket(ws)
      AllClients.remove(ws)
      AllClients.system_broadcast "#{client.display_name} has disconnected."
      AllClients.roster_update
    end

    ws.onmessage do |message_json|
      puts "Received message_json: #{message_json}"

      client = AllClients.find_by_socket(ws)
      message = Message.create_for_user_from_json_string(client.user, message_json)

      BotManager.process_message(message)
      message.save

      AllClients.client_broadcast message
    end
  end

  file_descriptor = IO.sysopen(asynchronous_incoming_pipe_path, Fcntl::O_RDONLY|Fcntl::O_NONBLOCK)
  io_stream = IO.new(file_descriptor, Fcntl::O_RDONLY|Fcntl::O_NONBLOCK)
  pipe_watcher = EventMachine.watch(io_stream, AsynchronousMessageHandler)
  pipe_watcher.notify_readable = true

  file_descriptor = IO.sysopen(message_factory_incoming_pipe_path, Fcntl::O_RDONLY|Fcntl::O_NONBLOCK)
  io_stream = IO.new(file_descriptor, Fcntl::O_RDONLY|Fcntl::O_NONBLOCK)
  pipe_watcher = EventMachine.watch(io_stream, MessageFactoryHandler)
  pipe_watcher.notify_readable = true
end
