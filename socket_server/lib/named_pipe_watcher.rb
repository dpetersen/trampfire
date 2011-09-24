module NamedPipeWatcher
  # Public: Sets up an EventMachine watch for a named pipe.
  #
  # path - Path to the named pipe.
  # handler - Handler module with methods that correspond to EventMachine
  #           watch events.
  #
  # Returns nothing.
  def self.watch_at(path, handler)
    file_descriptor = IO.sysopen(path, Fcntl::O_RDONLY|Fcntl::O_NONBLOCK)
    io_stream = IO.new(file_descriptor, Fcntl::O_RDONLY|Fcntl::O_NONBLOCK)
    pipe_watcher = EventMachine.watch(io_stream, handler)
    pipe_watcher.notify_readable = true
  end
end
