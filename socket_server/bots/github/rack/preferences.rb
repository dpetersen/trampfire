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
        response_pipe_path = create_anonymous_pipe
        response_pipe = connect_named_pipe(response_pipe_path)

        interprocess_message = BotInitiatedInterprocessMessage.new(
          "GithubBot",
          "fetch_repository_watches",
          response_pipe_path: response_pipe_path
        )

        github_bot_pipe = incoming_pipe_for_bot("github")
        github_bot_pipe.puts interprocess_message.to_json
        github_bot_pipe.flush

        puts "About to wait for response at #{response_pipe.inspect}"
        @repository_watches = JSON.parse(response_pipe.gets)

        haml :preferences
      end

      post "/watch" do
        response_pipe_path = create_anonymous_pipe
        response_pipe = connect_named_pipe(response_pipe_path)

        interprocess_message = BotInitiatedInterprocessMessage.new(
          "GithubBot",
          "create_repository_watch",
          message_hash: params[:repository_watch].to_json,
          response_pipe_path: response_pipe_path
        )

        github_bot_pipe = incoming_pipe_for_bot("github")
        github_bot_pipe.puts interprocess_message.to_json
        github_bot_pipe.flush

        repository_watch = JSON.parse(response_pipe.gets)
        if repository_watch["id"].nil?
          "Error saving repository watch: #{repository_watch["errors"]}"
        else
          "Successfully saved repository watch."
        end
      end
    end
  end
end
