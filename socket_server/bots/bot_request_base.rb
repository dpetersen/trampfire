require File.join(File.dirname(__FILE__), 'pipe_connector')
require 'erubis'

class BotRequestBase
  include PipeConnector

  attr_reader :parent_bot_class
  attr_accessor :message_hash, :message

  def initialize(parent_bot_class, message_hash)
    @parent_bot_class = parent_bot_class
    self.message_hash = message_hash
    self.message = message_hash["data"]
  end

  def config
    self.parent_bot_class.config
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

  def within_subprocess(&block)
    subprocess = Process.fork  do
      connect_asyncronous_pipe
      yield
    end
    Process.detach(subprocess)
  end
end
