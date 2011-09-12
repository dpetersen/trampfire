require '../app_base'

class Imager < AppBase
  def modify_message(message)
    if message =~ /^http(.*)\.(gif|jpg|jpeg|png)$/
      tag_html(message)
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
