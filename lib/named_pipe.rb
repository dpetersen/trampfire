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

  def self.anonymous_for_writing
    self.for_writing(new_anonymous_pipe_path)
  end

  def self.anonymous_for_reading
    self.for_reading(new_anonymous_pipe_path)
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

protected

  def self.new_anonymous_pipe_path
    "/tmp/#{Time.now.to_i}"
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
