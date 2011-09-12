require '../app_base'

class Imager < AppBase
  def process(message)
    if message =~ /^http(.*)\.(gif|jpg|jpeg|png)$/
      %{<a href="#{message}"><img src="#{message}" alt="#{message}" /></a>}
    else message
    end
  end
end

Imager.new
