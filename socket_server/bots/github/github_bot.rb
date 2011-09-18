require '../bot_base'
require '../bot_request_base'

class GithubBotRequest < BotRequestBase
  def process
    if message =~ /^http(s)?:\/\/(www\.)?github\.com(.*)$/
      octocatize_message
    end
  end

protected

  def octocatize_message
    %{<a href="#{message}"><img src="http://th00.deviantart.net/fs70/150/i/2011/178/a/f/octocat_by_rstovall-d3k6a7n.jpg" />#{message}</a>}
  end
end

class GithubBot < BotBase
end

GithubBot.new
