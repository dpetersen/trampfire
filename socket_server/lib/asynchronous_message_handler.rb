module AsynchronousMessageHandler
  def self.create_incoming_pipe(path)
    `mkfifo #{path}` unless File.exists?(path)
  end

  def notify_readable
    begin
      interprocess_message_string = @io.readline
      interprocess_message = InterprocessMessage.from_json(interprocess_message_string)

      message = Message.find(interprocess_message.message["id"])
      message.update_attribute(:final_message, interprocess_message.message["data"])

      case interprocess_message.class.name
      when "BotInitiatedInterprocessMessage"
        AllClients.client_broadcast(message)
      when "UserInitiatedInterprocessMessage"
        AllClients.update_broadcast(message)
      else raise "Asynchronous InterprocessMessage is of unknown type: #{interprocess_message.inspect}"
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
