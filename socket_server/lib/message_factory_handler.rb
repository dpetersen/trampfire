require './bots/pipe_connector'

module MessageFactoryHandler
  include PipeConnector

  def self.create_incoming_pipe(path)
    `mkfifo #{path}` unless File.exists?(path)
  end

  def notify_readable
    begin
      interprocess_message_string = @io.readline
      interprocess_message = InterprocessMessage.from_json(interprocess_message_string)

      message = Message.create!(interprocess_message.message)

      response_pipe = connect_named_pipe(interprocess_message.response_pipe_path)
      response_pipe.puts message.as_json.to_json
      response_pipe.flush
    rescue EOFError
    end
  end

  def unbind
    EM.next_tick do
      puts "*"*100
      puts "I lost my connection to the AsynchronousMessageHandler named pipe!"
      puts "*"*100
    end
  end
end
