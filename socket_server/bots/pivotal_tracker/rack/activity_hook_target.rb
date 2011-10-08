require 'json'
require 'sinatra'

require File.join(PATHS::SOCKET_SERVER::LIB, 'interprocess_message')

module PivotalTrackerBot
  module Rack
    class ActivityHookTarget < Sinatra::Base

      post '/' do
        BotInitiatedInterprocessMessage.new(
          "pivotal_tracker",
          "activity_hook",
          message_hash: params[:body]
        ).send_to_bot

        "Success..." # I guess, if it gets here.
      end
    end
  end
end
