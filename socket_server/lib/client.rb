class Client
  attr_reader :socket, :user

  def initialize(socket)
    @socket = socket

    # TODO Once we find out how to get the cookie passed, this garbage
    # has got to go.
    @user = User.find_by_email!(socket.request["query"]["email"])
  end

  def send(message)
    socket.send message
  end

  def display_name
    @user.display_name
  end
end
