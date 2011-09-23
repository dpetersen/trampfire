module PipeConnector
  def connect_asyncronous_pipe
    return if @asynchronous_pipe

    path = File.join(File.dirname(__FILE__), 'asynchronous_incoming_pipe_path')
    @asynchronous_pipe = connect_named_pipe(
      path,
      "Can't connect to asynchronous named pipe!"
    )
  end

  def connect_message_factory_pipe
    return if @message_factory_pipe

    path = File.join(File.dirname(__FILE__), '../message_factory_incoming_pipe')
    @message_factory_pipe = connect_named_pipe(
      path,
      "Can't connect to message factory named pipe at '#{path}'!"
    )
  end

  # Fetch the connected message_factory_pipe.  This thing isn't necessarily
  # ready when the bots come up, if they start faster than the socket server.
  def message_factory_pipe
    connect_message_factory_pipe
    @message_factory_pipe
  end

  def incoming_pipe_for_bot(bot_name)
    path = File.join(File.dirname(__FILE__), "activated/#{bot_name}/incoming")
    connect_named_pipe(
      path,
      "Can't connect to named pipe for bot '#{bot_name}'!"
    )
  end

  def connect_named_pipe(path, failure_message = nil)
    if File.exist?(path)
      open(path, "w+")
    else raise failure_message || "Can't connect to named pipe: '#{path}'"
    end
  end

  def create_anonymous_pipe
    # TODO: Need to do something better than this
    path = "/tmp/#{Time.now.to_i}"
    `mkfifo #{path}`
    path
  end
end
