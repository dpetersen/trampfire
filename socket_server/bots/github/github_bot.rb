require '../bot_base'
require '../bot_request_base'

require 'pry'

class GithubBotRequest < BotRequestBase
  def process
    if message =~ /^http(?:s)?:\/\/(?:www\.)?github\.com\/([^\/]+)\/([^\/]+)\/commit\/([a-f0-9]{40})$/
      @user = $1
      @repo = $2
      @sha = $3

      within_subprocess do
        sleep 1
        message_hash["data"] = "I am a message from a later time. #{@sha}."
        @asynchronous_pipe.puts message_hash.to_json
        @asynchronous_pipe.flush
      end

      octocatize_message(message)
    end
  end

protected

  def octocatize_message(message)
    octocat_image_url = "http://th00.deviantart.net/fs70/150/i/2011/178/a/f/octocat_by_rstovall-d3k6a7n.jpg"
    %{<a href="#{message}"><img src="#{octocat_image_url}" />#{message}</a>}
  end
end

class GithubBot < BotBase
end

GithubBot.new
