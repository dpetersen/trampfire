require 'pry'

require 'eventmachine'
require 'em-websocket'
require './lib/clients'
require './lib/client'

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
      if message[0] == "/"
        if message =~ /^\/name (.*)$/
          puts "Client wants to identify itself as #{$1}"
          client = AllClients.find_by_socket(ws)
          AllClients.system_broadcast "#{client.display_name} now known as #{$1}"
          client.nick = $1
        else
          puts "I don't know how to deal with this command."
        end
      else
        AllClients.client_broadcast AllClients.find_by_socket(ws), message
      end
    end
  end
end
