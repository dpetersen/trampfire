require 'json'
require 'sinatra'

require File.join(PATHS::SOCKET_SERVER::LIB, 'interprocess_message')

module GithubBot
  module Rack
    class PostCommitTarget < Sinatra::Base

      post '/' do
        repository_watch = \
          NamedPipe.with_anonymous_pipe_for_reading do |pipe|
            BotInitiatedInterprocessMessage.new(
              "github",
              "fetch_repository_watch_for_post_commit",
              message_hash: params[:payload],
              response_pipe: pipe
            ).send_to_bot

            pipe.read_json
          end

        intended_tag = Tag.where(name: repository_watch["destination_tag_name"]).first
        message = Message.create(
          original_message: params[:payload],
          tag: intended_tag,
          bot: "GithubBot"
        )

        BotInitiatedInterprocessMessage.new(
          "github",
          "post_commit",
          message: message
        ).send_to_bot

        "Success..." # I guess, if it gets here.
      end
    end
  end
end
