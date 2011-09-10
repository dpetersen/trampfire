require 'eventmachine'
require 'em-websocket'

class Clients
  attr_accessor :clients

  def initialize
    self.clients = []
  end

  def add(client)
    clients << client
  end

  def remove(socket)
    client = clients.detect { |c| c.socket == socket }
    clients.delete(client)
  end

  def count
    clients.length
  end

  def broadcast(message)
    clients.each { |c| c.send "Broadcast: #{message}" }
  end
end

class Client
  attr_reader :socket

  def initialize(socket)
    @socket = socket
  end

  def send(message)
    socket.send message
  end
end

AllClients = Clients.new
EventMachine.run do

  EventMachine::WebSocket.start(host: "0.0.0.0", port: 8080) do |ws|
    ws.onopen do
      puts "Connected!"
      AllClients.add(Client.new(ws))
      AllClients.broadcast "A client has joined.  Clients: #{AllClients.count}"
    end

    ws.onclose do
      puts "Disconnected..."
      AllClients.remove(ws)
      AllClients.broadcast "A client has disconnected. Clients: #{AllClients.count}"
    end

    ws.onmessage do |message|
      puts "Received Message: #{message}"
      AllClients.broadcast message
    end
  end
end
