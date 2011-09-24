module MessageFactoryHandler
  def notify_readable
    begin
      interprocess_message_string = @io.readline
      interprocess_message = InterprocessMessage.from_json(interprocess_message_string)

      message = Message.create!(interprocess_message.message)
      interprocess_message.respond_with(message.as_json.to_json)
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
