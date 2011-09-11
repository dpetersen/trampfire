class Client
  attr_accessor :nick
  attr_reader :socket, :user

  def initialize(socket)
    @socket = socket
    @user = User.find_by_email!(socket.request["query"]["email"])
    @nick = @user.email
  end

  def send(message)
    socket.send message
  end

  def display_name
    nick || "Anonymous User"
  end
end
