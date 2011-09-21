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

      if message.type == "bot" then AllClients.client_broadcast(message)
      else AllClients.update_broadcast(message)
      end

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
