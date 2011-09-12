class AppBase
  def initialize
    connect_incoming_pipe

    wait_for_incoming
  end

protected

  def connect_incoming_pipe
    path = "incoming"
    `mkfifo #{path}` unless File.exist?(path)
    @incoming_pipe = open("incoming", "r+")
  end

  # Called at message time, not on initialize.  If the pipe doesn't
  # exist, Ruby creates a file in its place.  On first launch, it
  # probably won't be there by the time this initializes.
  def connect_outgoing_pipe
    return if @outgoing_pipe

    path = "../app_manager_incoming"
    @outgoing_pipe = open(path, "w+") if File.exist?(path)
  end

  def wait_for_incoming
    puts "Waiting"

    message = @incoming_pipe.gets.strip!
    puts "Got message: #{message}"
    message = process(message)

    puts "Message modded to: #{message}"
    connect_outgoing_pipe
    @outgoing_pipe.puts message
    @outgoing_pipe.flush

    wait_for_incoming
  end
end
