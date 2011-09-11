class Imager
  def initialize
    @incoming_pipe = open("incoming", "r+")
    @outgoing_pipe = open("outgoing", "w+")

    wait_for_incoming
  end

  def wait_for_incoming
    puts "Waiting"

    message = @incoming_pipe.gets.strip!
    puts "Got message: #{message}"
    message = process(message)

    puts "Message modded to: #{message}"
    @outgoing_pipe.puts message
    @outgoing_pipe.flush

    wait_for_incoming
  end

  def process(message)
    if message =~ /^http(.*)\.(gif|jpg|jpeg|png)$/
      %{<a href="#{message}"><img src="#{message}" alt="#{message}" /></a>}
    else message
    end
  end
end

Imager.new
