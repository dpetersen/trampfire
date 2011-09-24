require_relative '../../../paths'

require File.join(PATHS::SOCKET_SERVER::BOT_LIB, 'bot_essentials')

class ImageBotRequest < BotRequestBase
  def process
    if message =~ /^http(.*)\.(gif|jpg|jpeg|png)$/
      tag_html
    end
  end

protected

  def tag_html
    <<-eos
      <a href="#{message}">
        <img src="#{message}" alt="#{message}" />
      </a>
    eos
  end
end

class ImageBot < BotBase
end
ImageBot.new
