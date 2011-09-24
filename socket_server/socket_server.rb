require 'fcntl'
require 'eventmachine'
require 'em-websocket'
require 'active_record'

require_relative '../lib/shared'

require_relative 'lib/libs'
require File.join(PATHS::SHARED::BASE, 'database_config')
require File.join(PATHS::SHARED::MODELS, 'models')

ActiveRecord::Base.establish_connection(
  adapter: DatabaseConfig.adapter,
  host: DatabaseConfig.host,
  username: DatabaseConfig.username,
  password: DatabaseConfig.password,
  database: DatabaseConfig.database
)

AllClients = Clients.new

asynchronous_incoming_pipe_path = File.join(PATHS::SOCKET_SERVER::BOTS, 'asynchronous_incoming_pipe_path')
message_factory_incoming_pipe_path = File.join(PATHS::SOCKET_SERVER::BASE, 'message_factory_incoming_pipe')

# For OSX support, apparently
EventMachine.kqueue = true if EventMachine.kqueue?

EventMachine.run do
  EventMachine::WebSocket.start(host: "0.0.0.0", port: 31981) do |ws|
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

  NamedPipeWatcher.watch_at(asynchronous_incoming_pipe_path, AsynchronousMessageHandler)
  NamedPipeWatcher.watch_at(message_factory_incoming_pipe_path, MessageFactoryHandler)
end
