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
