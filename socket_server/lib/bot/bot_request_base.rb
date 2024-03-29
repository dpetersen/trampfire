require_relative 'subprocessor'

class BotRequestBase
  include ViewHelpers
  include Subprocessor

  attr_reader :parent_bot_class, :parent_bot
  attr_accessor :message_hash, :message

  def self.handle_bot_event(event_name, handler_module = nil, &handler_block)
    @bot_event_handlers ||= {}

    handler = if block_given? then handler_block
              else handler_module
              end

    @bot_event_handlers[event_name] = handler
  end

  def self.handler_for_event(event_name)
    @bot_event_handlers[event_name]
  end

  def initialize(parent_bot, parent_bot_class, message_hash)
    @parent_bot = parent_bot
    @parent_bot_class = parent_bot_class
    self.message_hash = message_hash
    self.message = message_hash["data"] if message_hash
  end

  def config
    self.parent_bot_class.config
  end

  protected

  def bot_lowercase_name
    self.class.name.underscore.gsub(/_bot_request/, '')
  end
end
