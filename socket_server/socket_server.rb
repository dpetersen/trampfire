require 'pry'

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
EventMachine.run do

  EventMachine::WebSocket.start(host: "0.0.0.0", port: 8080) do |ws|
    ws.onopen do
      puts "Connected!"
      AllClients.add(Client.new(ws))
      AllClients.system_broadcast "A client has joined.  Client Count: #{AllClients.count}"
    end

    ws.onclose do
      puts "Disconnected..."
      client = AllClients.find_by_socket(ws)
      AllClients.remove(ws)
      AllClients.system_broadcast "#{client.display_name} has disconnected. Client Count: #{AllClients.count}"
    end

    ws.onmessage do |message_json|
      puts "Received message_json: #{message_json}"

      client = AllClients.find_by_socket(ws)
      message = Message.create_for_user_from_json_string(client.user, message_json)

      puts "Before: #{message.inspect}"
      AppManager.process(message)

      message.save
      puts "After: #{message.inspect}"
      AllClients.client_broadcast message
    end
  end
end
