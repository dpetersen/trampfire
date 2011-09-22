require File.join(File.dirname(__FILE__), '../../../pipe_connector')
require 'json'
require 'haml'
require 'sinatra'

module GithubBot
  module Rack
    class Preferences < Sinatra::Base
      include PipeConnector

      set :views, File.dirname(__FILE__) + '/views'

      get "/" do
        haml :preferences
      end

      post "/watch" do
        interprocess_message = BotInitiatedInterprocessMessage.new(
          "GithubBot",
          "create_repository_watch",
          message_hash: params[:repository_watch].to_json
        )

        github_bot_pipe = incoming_pipe_for_bot("github")
        github_bot_pipe.puts interprocess_message.to_json
        github_bot_pipe.flush

        "Success...?"
      end
    end
  end
end
