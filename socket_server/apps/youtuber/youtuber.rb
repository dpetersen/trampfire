class Youtuber
  def initialize
    @incoming_pipe = open("incoming", "r+")
    @outgoing_pipe = open("../outgoing", "w+")

    wait_for_incoming
  end

  def wait_for_incoming
    puts "Waiting"

    message = @incoming_pipe.gets.strip!
    puts "Got message: #{message}"
    message = process(message)

    puts "Message modded to: #{message}"
    @outgoing_pipe.puts message
    @outgoing_pipe.flush

    wait_for_incoming
  end

  def process(message)
    if message =~ /^http:\/\/www\.youtube\.com\/watch\?v\=(.*)$/
      video_id = $1
      %{<object type="application/x-shockwave-flash" style="width:450px; height:366px;" data="http://www.youtube.com/v/#{video_id}" > <param name="movie" value="http://www.youtube.com/v/#{video_id}" /> </object>}
    else message
    end
  end
end

Youtuber.new
