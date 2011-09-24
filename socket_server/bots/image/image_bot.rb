require_relative '../../../lib/shared'

require File.join(PATHS::SOCKET_SERVER::BOT_LIB, 'bot_essentials')

class ImageBotRequest < BotRequestBase
  def process_user_initiated_message
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
