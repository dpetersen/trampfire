require 'pry'
require 'sinatra'

class TrampfireApp < Sinatra::Base
  get '/' do
    if env['warden'].authenticated?
      haml :index
    else
      haml :login
    end
  end

  get '/application.js' do
    coffee :application
  end
end
