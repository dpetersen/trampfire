require 'json'
require 'sinatra'

require File.join(PATHS::SOCKET_SERVER::LIB, 'interprocess_message')

module GithubBot
  module Rack
    class PostCommitTarget < Sinatra::Base

      post '/' do
        begin
          message = Message.create(original_message: params[:payload], tag: Tag.first, bot: "GithubBot")

          interprocess_message = BotInitiatedInterprocessMessage.new(
            "GithubBot",
            "post_commit",
            message: message
          )

          NamedPipe.for_writing_for_bot("github").write(interprocess_message.to_json)

          interprocess_message.inspect
        rescue Exception => e
          e.message
        end
      end
    end
  end
end
