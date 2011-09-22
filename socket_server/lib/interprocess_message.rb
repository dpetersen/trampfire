require 'json'

class InterprocessMessage
  TYPES = {
    user_initiated: "user_initiated",
    bot_initiated: "bot_initiated"
  }

  attr_accessor :type, :event, :message, :bot_name, :event_name

  # Public: Create a new InterprocessMessage.
  #
  # type - A symbol defining the type, which should use TYPES constant.
  # options - A hash of optional arguments.  Pass message OR message_hash (default: {}):
  #           :message - A Message model instance.
  #           :message_hash - A hash representation of a Message.
  #           :bot_name - For bot_initiated events, which bot should handle.
  #           :event_name - For bot_initiated events, what type of event is this.
  #
  # Returns the new InterprocessMessage.
  def initialize(type, options = {})
    self.type = TYPES[type]
    self.message = options[:message_hash] if options[:message_hash]
    self.message = options[:message].as_json if options[:message]
    self.bot_name = options[:bot_name].as_json if options[:bot_name]
    self.event_name = options[:event_name].as_json if options[:event_name]
  end

  def self.from_json(json)
    object = JSON.parse(json)

    if object["type"] == TYPES[:user_initiated]
      self.new(:user_initiated, message_hash: object["message"])
    elsif object["type"] == TYPES[:bot_initiated]
      self.new(
        :bot_initiated,
        message_hash: object["message"],
        bot_name: object["bot_name"],
        event_name: object["event_name"]
      )
    else raise "I can't reconstitute the InterprocessMessage #{json}"
    end
  end

  def to_json
    base_hash = { type: type }

    if type == TYPES[:bot_initiated]
      base_hash.merge!(bot_name: bot_name, event_name: event_name)
    end

    base_hash.merge!(message: message) if message

    base_hash.to_json
  end
end
