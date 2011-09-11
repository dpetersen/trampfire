# This MUST go before sinatra/activerecord is required.  How the fuck
# that thing actually works as documented... well, it doesn't.
ENV["DATABASE_URL"] = "mysql2://localhost/trampfire_development"

require 'pry'
require 'sinatra'
require 'sinatra/activerecord'
require './lib/authorization_helpers'
require './models/user'

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
