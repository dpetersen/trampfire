require 'json'
require 'sinatra'

require File.join(PATHS::SOCKET_SERVER::LIB, 'interprocess_message')

module GithubBot
  module Rack
    class PostCommitTarget < Sinatra::Base

      post '/' do
        begin
          message = Message.create(original_message: params[:payload], tag: Tag.first, bot: "GithubBot")

          BotInitiatedInterprocessMessage.new(
            "github",
            "post_commit",
            message: message
          ).send_to_bot

          "Success..." # I guess, if it gets here.
        rescue Exception => e
          e.message
        end
      end
    end
  end
end
