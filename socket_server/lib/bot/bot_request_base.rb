require 'erubis'

require_relative 'subprocessor'

class BotRequestBase
  include Subprocessor

  attr_reader :parent_bot_class, :parent_bot
  attr_accessor :message_hash, :message

  def self.handle_bot_event(event_name, &handler)
    @bot_event_handlers ||= {}
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

  def asynchronous_pipe
    self.parent_bot.asynchronous_pipe
  end

  def render_view(view, variables = {})
    template = File.open("views/#{view}.html.erb", variables).read
    Erubis::Eruby.new(template).result(variables)
  end

  protected

  def public_asset_path(path)
    "/bots/#{bot_lowercase_name}/public#{path}"
  end

  def bot_lowercase_name
    self.class.name.underscore.gsub(/_bot_request/, '')
  end
end
