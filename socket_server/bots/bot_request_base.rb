require 'erubis'

class BotRequestBase
  attr_reader :parent_bot_class
  attr_accessor :message_hash, :message

  def initialize(parent_bot_class, message_hash)
    @parent_bot_class = parent_bot_class
    self.message_hash = message_hash
    self.message = message_hash["data"]
  end

  def config
    self.parent_bot_class.config
  end

  def render_view(view, variables = {})
    template = File.open("views/#{view}.html.erb", variables).read
    Erubis::Eruby.new(template).result(variables)
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
