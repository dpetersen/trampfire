module AsynchronousMessageHandler
  def self.create_incoming_pipe(path)
    `mkfifo #{path}` unless File.exists?(path)
  end

  def notify_readable
    begin
      message_string = @io.readline
      message_object = JSON.parse(message_string)
      message = Message.find(message_object["id"])
      message.update_attribute(:final_message, message_object["data"])

      AllClients.update_broadcast message
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
