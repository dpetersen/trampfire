require 'pry'

require '../database_config'

# This MUST go before sinatra/activerecord is required.  How the fuck
# that thing actually works as documented... well, it doesn't.
ENV["DATABASE_URL"] = DatabaseConfig.connection_string

require 'sinatra'
require 'sinatra/activerecord'
require './lib/authorization_helpers'
require '../models/user'

class TrampfireApp < Sinatra::Base
  set :public, 'public'

  include AuthorizationHelpers

  get '/' do
    when_authenticated do
      haml :index, layout: :application
    end
  end

  get '/application.js' do
    coffee :application
  end
end
