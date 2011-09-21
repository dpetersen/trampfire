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
        params[:repository_watch].inspect
      end

      # post '/' do
      #   begin
      #     m = Message.create(original_message: params[:payload], tag: Tag.first, bot: "GithubBot")

      #     github_bot_pipe = incoming_pipe_for_bot("github")
      #     github_bot_pipe.puts m.as_json.to_json
      #     github_bot_pipe.flush

      #     m.inspect
      #   rescue Exception => e
      #     e.message
      #   end
      # end
    end
  end
end
