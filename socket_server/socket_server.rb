require 'pry'

require 'eventmachine'
require 'em-websocket'
require './lib/clients'
require './lib/client'
require './app_manager'

require 'active_record'
require '../models/user'
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

    ws.onmessage do |message|
      puts "Received Message: #{message}"

      message = AppManager.process(message)
      AllClients.client_broadcast AllClients.find_by_socket(ws), message
    end
  end
end
