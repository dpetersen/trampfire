require '../app_base'

class Imager < AppBase
  def process(message_json)
    message_hash = deserialize_message_json(message_json)
    data = message_hash["data"]

    if data =~ /^http(.*)\.(gif|jpg|jpeg|png)$/
      serialize_message_hash(
        message_hash, 
        tag_html(data)
      )
    else message_json
    end
  end

protected

  def tag_html(url)
    <<-eos
      <a href="#{url}">
        <img src="#{url}" alt="#{url}" />
      </a>
    eos
  end
end

Imager.new
