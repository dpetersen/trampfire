require 'json'
require 'haml'
require 'sinatra'

require File.join(PATHS::SOCKET_SERVER::LIB, 'interprocess_message')

module DeploymentBot
  module Rack
    class Preferences < Sinatra::Base
      set :views, File.dirname(__FILE__) + '/views'

      get "/" do
        @projects = \
          NamedPipe.with_anonymous_pipe_for_reading do |pipe|
            BotInitiatedInterprocessMessage.new(
              "deployment",
              "fetch_projects",
              response_pipe: pipe
            ).send_to_bot

            pipe.read_json
          end

        haml :preferences
      end

      post "/projects" do
        project = \
          NamedPipe.with_anonymous_pipe_for_reading do |pipe|
            BotInitiatedInterprocessMessage.new(
              "deployment",
              "create_project",
              message_hash: params[:project].to_json,
              response_pipe: pipe
            ).send_to_bot

            pipe.read_json
          end

        if project["id"].nil?
          "Error saving project: #{project["errors"]}"
        else
          "Successfully saved project."
        end
      end
    end
  end
end
