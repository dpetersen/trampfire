require 'json'
require 'sinatra'

require File.join(PATHS::SOCKET_SERVER::LIB, 'interprocess_message')

module GithubBot
  module Rack
    class PostCommitTarget < Sinatra::Base

      post '/' do
        BotInitiatedInterprocessMessage.new(
          "github",
          "post_commit",
          message_hash: params[:payload]
        ).send_to_bot

        "Success..." # I guess, if it gets here.
      end
    end
  end
end
