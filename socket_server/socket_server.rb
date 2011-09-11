require 'eventmachine'
require 'em-websocket'
require 'pry'

class Clients
  attr_accessor :clients

  def initialize
    self.clients = []
  end

  def add(client)
    clients << client
  end

  def find_by_socket(socket)
    clients.detect { |c| c.socket == socket }
  end

  def remove(socket)
    clients.delete(find_by_socket(socket))
  end

  def count
    clients.length
  end

def system_broadcast(message)
  broadcast "System: #{message}"
end

def client_broadcast(client, message)
  broadcast "#{client.display_name}: #{message}"
end

protected

  def broadcast(message)
    clients.each { |c| c.send message }
  end
end

class Client
  attr_accessor :nick
  attr_reader :socket, :email

  def initialize(socket)
    @socket = socket
    @email = socket.request["query"]["email"]
    @nick = email
  end

  def send(message)
    socket.send message
  end

  def display_name
    nick || "Anonymous User"
  end
end

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
