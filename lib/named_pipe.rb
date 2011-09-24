require 'json'

class NamedPipe
  def self.for_reading(path)
    self.new(path, "r+")
  end

  def self.for_writing(path)
    self.new(path, "w+")
  end

  def self.for_writing_for_bot(bot_name)
    self.for_writing(path_to_bot_pipe(bot_name))
  end

  def self.with_anonymous_pipe_for_reading(&block)
    anonymous_pipe = self.for_reading(new_anonymous_pipe_path)
    return_value = yield anonymous_pipe
    anonymous_pipe.destroy
    return_value
  end

  def self.message_factory_pipe
    path = File.join(PATHS::SOCKET_SERVER::BASE, 'message_factory_incoming_pipe')
    NamedPipe.for_writing(path)
  end

  def self.asynchronous_pipe
    path = File.join(PATHS::SOCKET_SERVER::BOTS, 'asynchronous_incoming_pipe_path')
    NamedPipe.for_writing(path)
  end

  attr_reader :path

  def initialize(path, permissions)
    raise "A path is required!" unless path
    raise "Permissins are required!" unless permissions

    @path = path
    @permissions = permissions
    connect
  end

  def write(s)
    @pipe.puts s
    @pipe.flush
  end

  def read
    @pipe.gets
  end

  def read_json
    JSON.parse(read)
  end

  def destroy
    @pipe.close
    `rm #{@path}`
  end

protected

  def self.new_anonymous_pipe_path
    "/tmp/#{Time.now.to_i}.#{$$}"
  end

  def self.path_to_bot_pipe(bot_name)
    File.join(PATHS::SOCKET_SERVER::ACTIVATED_BOTS, bot_name, "incoming")
  end

  def connect
    create_if_nonexistant
    @pipe = open(@path, @permissions)
  end

  def create_if_nonexistant
    unless File.exist?(@path)
      `mkfifo #{@path}`
    end
  end
end
