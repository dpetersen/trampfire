require '../app_base'

class Imager < AppBase
  def process(message_json)
    message_hash = deserialize_message_json(message_json)
    data = message_hash["data"]

    if data =~ /^http(.*)\.(gif|jpg|jpeg|png)$/
      serialize_message_hash(
        message_hash, 
        %{<a href="#{data}"><img src="#{data}" alt="#{data}" /></a>}
      )
    else message_json
    end
  end
end

Imager.new
