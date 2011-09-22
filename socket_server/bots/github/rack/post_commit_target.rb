require File.join(File.dirname(__FILE__), '../../../pipe_connector')
require File.join(File.dirname(__FILE__), '../../../../lib/interprocess_message')
require 'json'
require 'sinatra'

module GithubBot
  module Rack
    class PostCommitTarget < Sinatra::Base
      include PipeConnector

      post '/' do
        begin
          message = Message.create(original_message: params[:payload], tag: Tag.first, bot: "GithubBot")

          interprocess_message = InterprocessMessage.new(
            :bot_initiated,
            bot_name: "GithubBot",
            event_name: "post_commit",
            message: message
          )

          github_bot_pipe = incoming_pipe_for_bot("github")
          github_bot_pipe.puts interprocess_message.to_json
          github_bot_pipe.flush

          interprocess_message.inspect
        rescue Exception => e
          e.message
        end
      end
    end
  end
end
