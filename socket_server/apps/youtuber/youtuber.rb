require '../app_base'

class Youtuber < AppBase
  def process(message)
    if message =~ /^http:\/\/www\.youtube\.com\/watch\?v\=(.*)$/
      video_id = $1
      %{<object type="application/x-shockwave-flash" style="width:450px; height:366px;" data="http://www.youtube.com/v/#{video_id}" > <param name="movie" value="http://www.youtube.com/v/#{video_id}" /> </object>}
    else message
    end
  end
end

Youtuber.new
