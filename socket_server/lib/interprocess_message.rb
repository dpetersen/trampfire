require 'json'

class InterprocessMessage
  TYPES = { chat: "chat" }

  attr_accessor :type, :message, :data

  # Public: Create a new InterprocessMessage.
  #
  # type - A symbol defining the type, which should use TYPES constant.
  # options - A hash of optional arguments.  Pass message OR message_hash (default: {}):
  #           :message - A Message model instance.
  #           :message_hash - A hash representation of a Message.
  #           :data - A hash.
  #
  # Returns the new InterprocessMessage.
  def initialize(type, options = {})
    self.type = TYPES[type]
    self.message = options[:message_hash] if options[:message_hash]
    self.message = options[:message].as_json if options[:message]
    self.data = options[:data] if options[:data]
  end

  def self.from_json(json)
    object = JSON.parse(json)

    if object["type"] == "chat"
      self.new(:chat, message_hash: object["message"])
    else raise "I can't reconstitute the InterprocessMessage #{json}"
    end
  end

  def to_json
    base_hash = {
      type: type
    }

    base_hash.merge!(message: message) if message
    base_hash.merge!(data: data) if data

    base_hash.to_json
  end
end
