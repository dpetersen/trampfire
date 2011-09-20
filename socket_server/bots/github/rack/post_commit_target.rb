require 'json'
require 'sinatra'

module GithubBot
  module Rack
    class PostCommitTarget < Sinatra::Base
      get '/' do
        raise JSON.parse(params[:payload]).to_s
      end
    end
  end
end
