require 'json'
require 'haml'
require 'sinatra'

module GithubBot
  module Rack
    class Preferences < Sinatra::Base
      set :views, File.dirname(__FILE__) + '/views'

      get "/" do
        @repository_watches = \
          NamedPipe.with_anonymous_pipe_for_reading do |pipe|
            BotInitiatedInterprocessMessage.new(
              "github",
              "fetch_repository_watches",
              response_pipe: pipe
            ).send_to_bot

            pipe.read_json
          end

        haml :preferences
      end

      post "/watch" do
        repository_watch = \
          NamedPipe.with_anonymous_pipe_for_reading do |pipe|
            BotInitiatedInterprocessMessage.new(
              "github",
              "create_repository_watch",
              message_hash: params[:repository_watch].to_json,
              response_pipe: pipe
            ).send_to_bot

            pipe.read_json
          end

        if repository_watch["id"].nil?
          "Error saving repository watch: #{repository_watch["errors"]}"
        else
          "Successfully saved repository watch."
        end
      end
    end
  end
end
