require 'json'
require 'haml'
require 'sinatra'

module GithubBot
  module Rack
    class Preferences < Sinatra::Base
      set :views, File.dirname(__FILE__) + '/views'

      get "/" do
        response_pipe = NamedPipe.anonymous_for_reading

        interprocess_message = BotInitiatedInterprocessMessage.new(
          "GithubBot",
          "fetch_repository_watches",
          response_pipe: response_pipe
        )

        NamedPipe.for_writing_for_bot("github").write(interprocess_message.to_json)

        @repository_watches = response_pipe.read_json

        haml :preferences
      end

      post "/watch" do
        response_pipe = NamedPipe.anonymous_for_reading

        interprocess_message = BotInitiatedInterprocessMessage.new(
          "GithubBot",
          "create_repository_watch",
          message_hash: params[:repository_watch].to_json,
          response_pipe: response_pipe
        )

        NamedPipe.for_writing_for_bot("github").write(interprocess_message.to_json)

        repository_watch = response_pipe.read_json
        if repository_watch["id"].nil?
          "Error saving repository watch: #{repository_watch["errors"]}"
        else
          "Successfully saved repository watch."
        end
      end
    end
  end
end
