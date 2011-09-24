require 'json'
require 'haml'
require 'sinatra'

module GithubBot
  module Rack
    class Preferences < Sinatra::Base
      set :views, File.dirname(__FILE__) + '/views'

      get "/" do
        response_pipe = NamedPipe.anonymous_for_reading

        BotInitiatedInterprocessMessage.new(
          "github",
          "fetch_repository_watches",
          response_pipe: response_pipe
        ).send_to_bot

        @repository_watches = response_pipe.read_json

        haml :preferences
      end

      post "/watch" do
        response_pipe = NamedPipe.anonymous_for_reading

        BotInitiatedInterprocessMessage.new(
          "github",
          "create_repository_watch",
          message_hash: params[:repository_watch].to_json,
          response_pipe: response_pipe
        ).send_to_bot

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
