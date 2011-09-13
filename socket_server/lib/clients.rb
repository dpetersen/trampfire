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
    broadcast system_json(message)
  end

  def client_broadcast(message)
    broadcast message.to_json
  end

  def roster_update
    broadcast(self.to_json)
  end

protected

  def to_json
    {
      type: "roster",
      clients: clients
    }.to_json
  end

  def broadcast(json)
    puts "Broadcasting #{json}"
    clients.each { |c| c.send json }
  end

  def system_json(message)
    {
      type: "system",
      data: message
    }.to_json
  end
end
