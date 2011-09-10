require 'eventmachine'
require 'em-websocket'

AllConnections = []
EventMachine.run do

  def broadcast(message)
    AllConnections.each { |c| c.send "Broadcast: #{message}" }
  end

  EventMachine::WebSocket.start(host: "0.0.0.0", port: 8080) do |ws|
    ws.onopen do
      puts "Connected!"
      AllConnections << ws
      broadcast "A client has joined.  Clients: #{AllConnections.length}"
    end

    ws.onclose do
      puts "Disconnected..."
      AllConnections.delete(ws)
      broadcast "A client has disconnected. Clients: #{AllConnections.length}"
    end

    ws.onmessage do |message|
      puts "Received Message: #{message}"
      ws.send "Pong: #{message}"
      broadcast message
    end
  end
end
