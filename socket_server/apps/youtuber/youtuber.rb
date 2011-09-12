require '../app_base'

class Youtuber < AppBase
  def process(message_json)
    message_hash = deserialize_message_json(message_json)
    data = message_hash["data"]

    if data =~ /^http:\/\/www\.youtube\.com\/watch\?v\=(.*)$/
      video_id = $1

      serialize_message_hash(
        message_hash,
        embed_html(video_id)
      )
    else message_json
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
