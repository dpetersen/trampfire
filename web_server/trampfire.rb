require 'pry'
require 'sinatra'

class TrampfireApp < Sinatra::Base
  set :public, 'public'

  get '/' do
    if env['warden'].authenticated?
      haml :index, layout: :application
    else
      haml :login, layout: :application
    end
  end

  get '/application.js' do
    coffee :application
  end
end
