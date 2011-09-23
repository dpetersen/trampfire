module PipeConnector
  def connect_asyncronous_pipe
    return if @asynchronous_pipe

    path = File.join(File.dirname(__FILE__), 'asynchronous_incoming_pipe_path')
    @asynchronous_pipe = connect_named_pipe(
      path,
      "Can't connect to asynchronous named pipe!"
    )
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

protected
end
