class BotRequestBase
  attr_accessor :message_hash, :message

  def initialize(message_hash)
    self.message_hash = message_hash
    self.message = message_hash["data"]
  end

  protected

  def within_subprocess(&block)
    subprocess = Process.fork  do
      connect_asyncronous_pipe
      yield
    end
    Process.detach(subprocess)
  end

  def connect_asyncronous_pipe
    return if @asynchronous_pipe

    path = "../asynchronous_incoming_pipe_path"
    if File.exist?(path)
      @asynchronous_pipe = open(path, "w+")
    else raise "Can't connect to asynchronous named pipe!"
    end
  end
end
