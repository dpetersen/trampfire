require 'pry'
require 'sinatra'
require './lib/authorization_helpers'

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
