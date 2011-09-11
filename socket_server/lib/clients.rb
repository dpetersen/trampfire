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
