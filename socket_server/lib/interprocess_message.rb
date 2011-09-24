require 'json'

class InterprocessMessage
  TYPES = {
    user_initiated: "user_initiated",
    bot_initiated: "bot_initiated",
    message_factory: "message_factory"
  }

  attr_accessor :type, :message

  # Should never be called directly.  This is a "virtual" class.
  def initialize(options)
    self.message = options[:message_hash] if options[:message_hash]
    self.message = options[:message].as_json if options[:message]
  end

  def self.from_json(json)
    object = JSON.parse(json)

    case object["type"]
    when TYPES[:user_initiated]
      UserInitiatedInterprocessMessage.new(
        message_hash: object["message"]
      )
    when TYPES[:bot_initiated]
      BotInitiatedInterprocessMessage.new(
        object["bot_name"],
        object["event_name"],
        message_hash: object["message"],
        response_pipe_path: object["response_pipe_path"]
      )
    when TYPES[:message_factory]
      MessageFactoryInterprocessMessage.new(
        NamedPipe.for_writing(object["response_pipe_path"]),
        message_hash: object["message"]
      )
    else raise "I can't reconstitute the InterprocessMessage #{json}"
    end
  end

  def response_pipe
    NamedPipe.for_reading(response_pipe_path) if response_pipe_path
  end

  def to_hash
    base_hash = { type: type }
    base_hash.merge!(message: message) if message
    base_hash
  end

  def to_json
    to_hash.to_json
  end
end

class UserInitiatedInterprocessMessage < InterprocessMessage
  # Public: Create a new UserInitiatedInterprocessMessage.
  #
  # options - A hash of arguments.  Pass message OR message_hash:
  #           :message - A Message model instance.
  #           :message_hash - A hash representation of a Message.
  #
  # Returns the new UserInitiatedInterprocessMessage.
  def initialize(options)
    self.type = InterprocessMessage::TYPES[:user_initiated]
    super(options)
  end
end

class BotInitiatedInterprocessMessage < InterprocessMessage

  attr_accessor :bot_name, :event_name
  attr_accessor :response_pipe_path

  # Public: Create a new BotInitiatedInterprocessMessage.
  #
  # bot_name - The class name of the destination bot, as a string.
  # event_name - The name of the event that the bot will handle.
  # options - A hash of arguments.  Pass message OR message_hash:
  #           :message - A Message model instance.
  #           :message_hash - A hash representation of a Message.
  #           :response_pipe - A NamedPipe instance where the sender
  #             will be awaiting a response.
  #
  # Returns the new BotInitiatedInterprocessMessage
  def initialize(bot_name, event_name, options)
    self.type = InterprocessMessage::TYPES[:bot_initiated]
    self.bot_name = bot_name
    self.event_name = event_name
    self.response_pipe_path = options[:response_pipe].path if options[:response_pipe]
    super(options)
  end

  def to_json
    self.to_hash.merge!(bot_name: bot_name, event_name: event_name, response_pipe_path: response_pipe_path).to_json
  end
end

class MessageFactoryInterprocessMessage < InterprocessMessage
  attr_accessor :response_pipe_path

  # Public: Create a new BotInitiatedInterprocessMessage.
  #
  # response_pipe: A NamedPipe instance where the requestor
  #   will be awaiting the created Message JSON.
  #
  # Returns the new MessageFactoryInterprocessMessage
  def initialize(response_pipe, options)
    self.type = InterprocessMessage::TYPES[:message_factory]
    self.response_pipe_path = response_pipe.path
    super(options)
  end

  def to_json
    self.to_hash.merge!(response_pipe_path: response_pipe_path).to_json
  end
end
