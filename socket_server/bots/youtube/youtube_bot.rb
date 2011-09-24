require_relative '../../../paths'

require File.join(PATHS::SOCKET_SERVER::BOT_LIB, 'bot_essentials')

class YoutubeBotRequest < BotRequestBase
  def process
    if message =~ /^http:\/\/www\.youtube\.com\/watch\?v\=(.*)$/
      embed_html($1)
    end
  end

protected
  
  def embed_html(video_id)
    <<-eos
      <object 
        type="application/x-shockwave-flash"
        style="width:450px; height:366px;"
        data="http://www.youtube.com/v/#{video_id}" 
      > 
        <param name="movie" value="http://www.youtube.com/v/#{video_id}" />
        <param name="wmode" value="opaque" />
      </object>
    eos
  end
end

class YoutubeBot < BotBase
end

YoutubeBot.new
