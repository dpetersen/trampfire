require '../app_base'

class Youtuber < AppBase
  def modify_message(message)
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
      </object>
    eos
  end
end

Youtuber.new
